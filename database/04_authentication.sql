CREATE OR REPLACE FUNCTION public.handle_new_user()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
BEGIN
    IF NEW.raw_user_meta_data->>'role' IS NULL
       OR NEW.raw_user_meta_data->>'role'
          NOT IN ('patient', 'caregiver') THEN
        RAISE EXCEPTION 'Invalid account role';
    END IF;

    IF NULLIF(TRIM(NEW.raw_user_meta_data->>'full_name'), '') IS NULL THEN
        RAISE EXCEPTION 'Full name is required';
    END IF;

    INSERT INTO public.profiles (
        id,
        full_name,
        role
    )
    VALUES (
        NEW.id,
        TRIM(NEW.raw_user_meta_data->>'full_name'),
        NEW.raw_user_meta_data->>'role'
    );

    RETURN NEW;
END;
$function$;

CREATE TRIGGER on_auth_user_created AFTER INSERT ON auth.users FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();
