import 'patient.dart';

class PatientDatabase {
  static List<Patient> patients = [];

  static void addPatient(Patient patient) {
    patients.add(patient);
  }

  static List<Patient> getPatients() {
    return patients;
  }
}