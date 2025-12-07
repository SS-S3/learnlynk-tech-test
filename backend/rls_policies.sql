-- LearnLynk Tech Test - Task 2: RLS Policies on leads

alter table public.leads enable row level security;

-- Example helper: assume JWT has tenant_id, user_id, role.
-- You can use: current_setting('request.jwt.claims', true)::jsonb

-- TODO: write a policy so:
-- - counselors see leads where they are owner_id OR in one of their teams
-- - admins can see all leads of their tenant


-- Example skeleton for SELECT (replace with your own logic):

create policy "leads_select_policy"
on public.leads
for select
using (
  tenant_id = ((current_setting('request.jwt.claims', true)::jsonb)->>'tenant_id')::uuid
  and (
    ((current_setting('request.jwt.claims', true)::jsonb)->>'role') = 'admin'
    or owner_id = ((current_setting('request.jwt.claims', true)::jsonb)->>'user_id')::uuid
    or owner_id in (
      select ut2.user_id from user_teams ut1
      join user_teams ut2 on ut1.team_id = ut2.team_id
      where ut1.user_id = ((current_setting('request.jwt.claims', true)::jsonb)->>'user_id')::uuid
    )
  )
);

-- TODO: add INSERT policy that:
-- - allows counselors/admins to insert leads for their tenant
-- - ensures tenant_id is correctly set/validated

create policy "leads_insert_policy"
on public.leads
for insert
with check (
  tenant_id = ((current_setting('request.jwt.claims', true)::jsonb)->>'tenant_id')::uuid
  and ((current_setting('request.jwt.claims', true)::jsonb)->>'role') in ('admin', 'counselor')
);
