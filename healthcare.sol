// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract Healthcare{

    // structure of Electronic Health Record.
    struct HealthRecord{
        string bloodGroup;
        uint8 heightInCm;
        address[] hospitalVisited;
        string[] MedicalHistory;
    }

    // structure of Patient.
    struct Patient{
        string name;
        uint8 age;
        address owner;
        address[] doctorAccessList;
        HealthRecord record;
    }

    // structure of Doctor.
    struct Doctor{
        string name;
        uint8 age;
        bool isEmployed;
        string registrationNo;
        uint8[] qualifications;
        uint8[] specializations;
        address[] patientAccessList;
        address currentHospital;
    }

    // structure of Hospital.
    struct Hospital{
        string name;
        address[] doctorsWorkingInHospital;
    }

    struct DoctorQualification{
        string abbr;
        string fullForm;
    }

    struct DoctorSpecialization{
        string abbr;
        string fullForm;
    }

    // These lists contain address of patients , doctors and hospitals.
    address[] allPatientsList;
    address[] allDoctorsList;
    address[] HospitalList;


    // Mapping is used to find the data in less time.

    mapping(address => Patient) PatientInfo;
    mapping(address => Doctor) DoctorInfo;
    mapping(address => Hospital) HospitalInfo;
    mapping(uint8 => mapping(address=>Doctor)) DoctorWithSpecialization;
    mapping(uint8 => DoctorSpecialization) SpecializationOfDoctors;
    mapping(uint8 => DoctorQualification) QualificationOfDoctors;

    uint credit = 0;

    // used to add to doctor to hospital
    function addDoctorToHospital(address daddr) public {
        if(bytes(HospitalInfo[msg.sender].name).length > 0){
            if(DoctorInfo[daddr].isEmployed){
                revert();
            }else{
                DoctorInfo[daddr].isEmployed = true;
                DoctorInfo[daddr].currentHospital = msg.sender;
                HospitalInfo[msg.sender].doctorsWorkingInHospital.push(daddr);
            }
        }else{
            revert();
        }
    }

    // Register a hospital
    function registerAsHospital(string memory _name) public{
        if(bytes(HospitalInfo[msg.sender].name).length > 0){
            revert();
        }
        Hospital memory h;
        h.name = _name;
        HospitalInfo[msg.sender] = h;
        HospitalList.push(msg.sender);
    }



    // Gets the list of hospital
    function getAllHospital() view public returns(string [] memory,address [] memory){
        string [] memory hospitalNames = new string[](HospitalList.length);
        for (uint i=0;i<HospitalList.length;i++){
            hospitalNames[i] = HospitalInfo[HospitalList[i]].name;
        }

        return (hospitalNames,HospitalList);
    }


    // Gets the hostipal details
    function getHospitalDetails(address haddr) view public returns(Hospital memory){
        return HospitalInfo[haddr];
    }

    // Used by patient for registration
    function registerAsPatient(string memory _name,uint8 _age,string memory _bloodGroup,uint8 _heightInCm) public {
        if(bytes(PatientInfo[msg.sender].name).length > 0){
            revert();
        }
        Patient memory p;
        p.name = _name;
        p.age = _age;
        p.owner = msg.sender;
        p.record.bloodGroup = _bloodGroup;
        p.record.heightInCm = _heightInCm;
        allPatientsList.push(msg.sender);
        PatientInfo[msg.sender] = p;
    }

    // Used to register doctor and check if doctor already exists at a particular address
    function registerAsDoctor(string memory _name,uint8 _age,string memory _registrationNo) public {
        if(bytes(DoctorInfo[msg.sender].name).length > 0){
            revert();
        }
        Doctor memory d;
        d.name = _name;
        d.age = _age;
        d.isEmployed = false;
        d.registrationNo = _registrationNo;
        d.specializations = new uint8[](256);
        d.qualifications = new uint8[](256);
        allDoctorsList.push(msg.sender);
        DoctorInfo[msg.sender] = d;
    }

    // Add specialization of a doctor

    function addSpecialization(address daddr,uint8 specializationCode) public {
        DoctorInfo[daddr].specializations[specializationCode] = 1;
    }

    function addQualification(address daddr,uint8 qualificationCode) public {
        DoctorInfo[daddr].qualifications[qualificationCode] = 1;
    }



    // This is used for getting which doctor is workinig in a hospital
    function getDoctorsWorkingInHospital(address haddr) view public returns (address[] memory){
        return HospitalInfo[haddr].doctorsWorkingInHospital;
    }

    // This method allows doctors to update any medical history.
    function addPatientReport(address paddr, string memory _report,address _hospital) public {

        bool found = false;
        address[] memory dl = PatientInfo[paddr].doctorAccessList;
        for(uint i=0;i<dl.length ;i++){
            if(dl[i]==msg.sender){
                found = true;
                break;
            }
        }
        if(!found){
            revert();
        }
        PatientInfo[paddr].record.hospitalVisited.push(_hospital);
        PatientInfo[paddr].record.MedicalHistory.push(_report);
    }

    function getAllDoctors() view public returns(address[] memory,string [] memory , string [] memory){
        uint len = allDoctorsList.length;
        string [] memory DoctorName = new string[](len);
        string [] memory DoctorRegistrationNo = new string[](len);

        for (uint i = 0 ; i < len; i++){
            DoctorName[i] = DoctorInfo[allDoctorsList[i]].name;
            DoctorRegistrationNo[i] = DoctorInfo[allDoctorsList[i]].registrationNo;
        }

        return (allDoctorsList,DoctorName,DoctorRegistrationNo);

    }

    // This method will see access and then permits to view record of a patient. 
    function getPatientsMedicalRecord(address paddr) view public returns (HealthRecord memory){
        if(msg.sender == paddr){
            return PatientInfo[paddr].record;
        }else{
            bool found = false;
            address[] memory dl = PatientInfo[paddr].doctorAccessList;
            for(uint i=0;i<dl.length ;i++){
                if(dl[i]==msg.sender){
                    found = true;
                    break;
                }
            }
            if(found){
                return PatientInfo[paddr].record;
            }else{
                revert();
            }
        }
    }

    // In this method , doctor can get patient details except previous health records.
    function get_patient_details(address paddr) view public returns (string memory , uint8 , string memory , uint8){
        return (PatientInfo[paddr].name , PatientInfo[paddr].age , PatientInfo[paddr].record.bloodGroup , PatientInfo[paddr].record.heightInCm);
    }

    // This method will help to get doctor's detail
    function get_doctor_details(address daddr) view public returns (string memory , uint){
        return (DoctorInfo[daddr].name, DoctorInfo[daddr].age);
    }

    // This method will give access to doctor to view record of a patient.
    function permit_access_to_doctor(address daddr) payable public {
        require(msg.value == 2 ether);
        credit += 2;
        DoctorInfo[daddr].patientAccessList.push(msg.sender);
        PatientInfo[msg.sender].doctorAccessList.push(daddr);
    }

    // Used as a helper function to remove Patients and doctor from accessing list.
    function remove_element_in_array(address[] storage Array, address addr) internal 
    {
        bool found = false;
        uint del_index = 0;
        for(uint i = 0; i<Array.length; i++){
            if(Array[i] == addr){
                found = true;
                del_index = i;
            }
        }
        if(!found) revert();
        else{
            Array[del_index] = Array[Array.length - 1];
            delete Array[Array.length - 1];
        }
    }

    // Patient can revoke access of a patient 
    function revoke_access(address daddr) public payable{
        remove_element_in_array(DoctorInfo[daddr].patientAccessList,msg.sender);
        remove_element_in_array(PatientInfo[msg.sender].doctorAccessList,daddr);
        payable(daddr).transfer(2 ether);
        credit -= 2;
    }

    // This will help patient in finding which doctor is accessing their data.
    function get_accessed_doctorlist_for_patient(address paddr) public view returns (address[] memory ,string [] memory , string [] memory)
    { 
        address [] memory docList = PatientInfo[paddr].doctorAccessList;
        string [] memory docNames = new string[](docList.length);
        string [] memory regNoOfDocs = new string[](docList.length);

        for (uint i = 0 ; i < docList.length ; i++){
            Doctor memory d= DoctorInfo[docList[i]];
            docNames[i] = d.name;
            regNoOfDocs[i] = d.registrationNo;
        }

        return (docList,docNames,regNoOfDocs);

    }

    // This will help doctors to see record of patients which doctor can access.
    function get_accessed_patientlist_for_doctor(address daddr) public view returns (address[] memory , string [] memory, uint8 [] memory)
    {
     

        address [] memory patList = DoctorInfo[daddr].patientAccessList;
        string [] memory patNames = new string[](patList.length);
        uint8 [] memory ageOfPatients = new uint8[](patList.length);

        for (uint i = 0 ; i < patList.length ; i++){
            Patient memory p = PatientInfo[patList[i]];
            patNames[i] = p.name;
            ageOfPatients[i] = p.age ;
        }

        return (patList,patNames,ageOfPatients);
    }

}
