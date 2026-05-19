-- C5 Sentinel-SAR analytics case-study SQL excerpts.
-- These snippets show the kind of warehouse/reporting logic used by the
-- operational repository. They are intentionally compact for portfolio review.

-- 1. Command summary without Cartesian join inflation.
-- Patients, alerts, and devices are aggregated separately before joining.

with patient_rollup as (
    select
        incident_id,
        count(*) as total_patients,
        count(*) filter (where triage_category = 'red') as red_patients,
        count(*) filter (where triage_category = 'yellow') as yellow_patients,
        count(*) filter (where triage_category = 'green') as green_patients,
        count(*) filter (where triage_category = 'black') as black_patients
    from patients
    group by incident_id
),
alert_rollup as (
    select
        incident_id,
        count(*) filter (where severity = 'critical' and resolved_at is null) as critical_open_alerts,
        count(*) filter (where resolved_at is null) as total_open_alerts
    from watchdog_alerts
    group by incident_id
),
device_rollup as (
    select
        incident_id,
        count(*) filter (where role = 'medic' and is_online = true) as active_medics,
        count(*) filter (where is_online = false) as stale_devices
    from device_presence
    group by incident_id
)
select
    i.id as incident_id,
    coalesce(p.total_patients, 0) as total_patients,
    coalesce(p.red_patients, 0) as red_patients,
    coalesce(a.critical_open_alerts, 0) as critical_open_alerts,
    coalesce(d.active_medics, 0) as active_medics,
    case
        when coalesce(d.active_medics, 0) = 0 then null
        else round(coalesce(p.red_patients, 0)::numeric / d.active_medics, 2)
    end as red_patients_per_active_medic,
    coalesce(d.stale_devices, 0) as stale_devices
from incidents i
left join patient_rollup p on p.incident_id = i.id
left join alert_rollup a on a.incident_id = i.id
left join device_rollup d on d.incident_id = i.id;

-- 2. Golden Hour compliance.

select
    incident_id,
    count(*) filter (where handed_over_at is not null) as handed_over_patients,
    count(*) filter (
        where handed_over_at is not null
          and handed_over_at <= injury_time + interval '60 minutes'
    ) as within_golden_hour,
    round(
        100.0 * count(*) filter (
            where handed_over_at is not null
              and handed_over_at <= injury_time + interval '60 minutes'
        ) / nullif(count(*) filter (where handed_over_at is not null), 0),
        1
    ) as golden_hour_compliance_pct
from patients
group by incident_id;

-- 3. Inventory stockout risk from an append-only ledger.

with current_stock as (
    select
        incident_id,
        item_code,
        location_id,
        sum(quantity_delta) as current_quantity
    from inventory_ledger
    group by incident_id, item_code, location_id
),
recent_burn as (
    select
        incident_id,
        item_code,
        location_id,
        abs(sum(quantity_delta)) / 60.0 as units_per_minute
    from inventory_ledger
    where quantity_delta < 0
      and occurred_at >= now() - interval '60 minutes'
    group by incident_id, item_code, location_id
)
select
    s.incident_id,
    s.item_code,
    s.location_id,
    s.current_quantity,
    b.units_per_minute,
    case
        when b.units_per_minute is null or b.units_per_minute = 0 then null
        else round(s.current_quantity / b.units_per_minute, 1)
    end as minutes_to_empty,
    case
        when s.current_quantity <= 0 then 'stockout'
        when b.units_per_minute > 0 and s.current_quantity / b.units_per_minute < 30 then 'critical'
        when b.units_per_minute > 0 and s.current_quantity / b.units_per_minute < 60 then 'watch'
        else 'ok'
    end as stockout_status
from current_stock s
left join recent_burn b
  on b.incident_id = s.incident_id
 and b.item_code = s.item_code
 and b.location_id = s.location_id;

-- 4. Sync latency health for offline-first command confidence.

select
    incident_id,
    percentile_cont(0.95) within group (
        order by extract(epoch from (server_received_at - occurred_at))
    ) as sync_latency_p95_seconds,
    count(*) filter (
        where server_received_at - occurred_at > interval '5 minutes'
    ) as stale_sync_events
from events
where server_received_at is not null
group by incident_id;
