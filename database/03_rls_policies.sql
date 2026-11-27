-- Enable RLS on all application tables as intended; verify live flags.
SET search_path TO public, extensions;
ALTER TABLE public.caregiver_patients ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.contacts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.medication_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.medications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.pairing_attempts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.pairing_codes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.task_completions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tasks ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Caregivers can view their patient links" ON public.caregiver_patients AS PERMISSIVE FOR SELECT TO authenticated
    USING ((caregiver_id = ( SELECT auth.uid() AS uid)));

CREATE POLICY "Patients can view their caregiver links" ON public.caregiver_patients AS PERMISSIVE FOR SELECT TO authenticated
    USING ((patient_id = ( SELECT auth.uid() AS uid)));

CREATE POLICY "linked caregiver manages contacts" ON public.contacts AS PERMISSIVE FOR ALL TO authenticated
    USING ((EXISTS ( SELECT 1
   FROM caregiver_patients cp
  WHERE ((cp.caregiver_id = auth.uid()) AND (cp.patient_id = contacts.patient_id)))))
    WITH CHECK ((EXISTS ( SELECT 1
   FROM caregiver_patients cp
  WHERE ((cp.caregiver_id = auth.uid()) AND (cp.patient_id = contacts.patient_id)))));

CREATE POLICY "patient reads own contacts" ON public.contacts AS PERMISSIVE FOR SELECT TO authenticated
    USING ((patient_id = auth.uid()));

CREATE POLICY "Enable read access for all users" ON public.medications AS PERMISSIVE FOR SELECT TO public
    USING (true);

CREATE POLICY "Users can read their own profile" ON public.profiles AS PERMISSIVE FOR SELECT TO authenticated
    USING ((auth.uid() = id));

CREATE POLICY "Users can view linked profiles" ON public.profiles AS PERMISSIVE FOR SELECT TO authenticated
    USING ((EXISTS ( SELECT 1
   FROM caregiver_patients cp
  WHERE (((cp.caregiver_id = auth.uid()) AND (cp.patient_id = profiles.id)) OR ((cp.patient_id = auth.uid()) AND (cp.caregiver_id = profiles.id))))));

CREATE POLICY "Caregivers can view patient completions" ON public.task_completions AS PERMISSIVE FOR SELECT TO authenticated
    USING ((EXISTS ( SELECT 1
   FROM tasks t
  WHERE ((t.id = task_completions.task_id) AND (t.caregiver_id = ( SELECT auth.uid() AS uid)) AND (t.patient_id = task_completions.patient_id)))));

CREATE POLICY "Patients can complete their tasks" ON public.task_completions AS PERMISSIVE FOR INSERT TO authenticated
    WITH CHECK (((patient_id = ( SELECT auth.uid() AS uid)) AND (EXISTS ( SELECT 1
   FROM tasks t
  WHERE ((t.id = task_completions.task_id) AND (t.patient_id = ( SELECT auth.uid() AS uid)))))));

CREATE POLICY "Patients can undo task completion" ON public.task_completions AS PERMISSIVE FOR DELETE TO authenticated
    USING (((patient_id = ( SELECT auth.uid() AS uid)) AND (EXISTS ( SELECT 1
   FROM tasks t
  WHERE ((t.id = task_completions.task_id) AND (t.patient_id = ( SELECT auth.uid() AS uid)))))));

CREATE POLICY "Patients can view their completions" ON public.task_completions AS PERMISSIVE FOR SELECT TO authenticated
    USING (((patient_id = ( SELECT auth.uid() AS uid)) AND (EXISTS ( SELECT 1
   FROM tasks t
  WHERE ((t.id = task_completions.task_id) AND (t.patient_id = task_completions.patient_id))))));

CREATE POLICY "Caregivers can create tasks" ON public.tasks AS PERMISSIVE FOR INSERT TO authenticated
    WITH CHECK ((caregiver_id = ( SELECT auth.uid() AS uid)));

CREATE POLICY "Caregivers can delete tasks" ON public.tasks AS PERMISSIVE FOR DELETE TO authenticated
    USING ((caregiver_id = ( SELECT auth.uid() AS uid)));

CREATE POLICY "Caregivers can update tasks" ON public.tasks AS PERMISSIVE FOR UPDATE TO authenticated
    USING ((caregiver_id = ( SELECT auth.uid() AS uid)))
    WITH CHECK (((caregiver_id = ( SELECT auth.uid() AS uid)) AND (EXISTS ( SELECT 1
   FROM caregiver_patients cp
  WHERE ((cp.caregiver_id = tasks.caregiver_id) AND (cp.patient_id = tasks.patient_id))))));

CREATE POLICY "Caregivers can view assigned tasks" ON public.tasks AS PERMISSIVE FOR SELECT TO authenticated
    USING ((caregiver_id = ( SELECT auth.uid() AS uid)));

CREATE POLICY "Patients can view their tasks" ON public.tasks AS PERMISSIVE FOR SELECT TO authenticated
    USING ((patient_id = ( SELECT auth.uid() AS uid)));

-- Pairing table restrictions from implementation conversation.
REVOKE ALL ON public.pairing_codes, public.pairing_attempts FROM PUBLIC, anon, authenticated;
