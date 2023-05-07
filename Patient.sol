// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "./library.sol";

contract PatientContract{

    struct Patient{
        bool exist;
        string name;
        uint8 age;
        uint8 bloodgroup;
        uint8 weightInKg;
        uint8 heightInCm;
        mapping(uint256 => MyStructs.Report) MedicalHistory;
        uint256 countOfReports;
        address [] doctorAccessList;
        mapping(address => bool) isDoctorAutherized;
        address owner;
    }

    using Helpers for address[];
    using MyStructs for MyStructs.ReturnFormatOfPatient;
    using MyStructs for MyStructs.Report;

    string [] bloodGroups = new string[](8);

    mapping(address => Patient ) PatientInfo;
    uint256 patientsCount = 0;

    mapping(uint8 => mapping(uint256 => address)) PatientWithSpecifiedBloodGroup;
    mapping(uint8 => uint256) countOfSpecializedBloodGroup;

    constructor(){
        init();
    }


    function init() internal{
        bloodGroups[0] = "A+";
        bloodGroups[1] = "A-";
        bloodGroups[2] = "O+";
        bloodGroups[3] = "O-";
        bloodGroups[4] = "B+";
        bloodGroups[5] = "B-";
        bloodGroups[6] = "AB+";
        bloodGroups[7] = "AB-";
    }

    // Tasks to be completed

    // Next Aim is to create blood group filtering for patient;


    modifier checkPatientExist(address paddr){
        require(PatientInfo[paddr].exist , "Patient's healthrecord already exists , cannot create new health record");
        _;
    }

    modifier checkNullAddress(address addr){
        require(addr != address(0),"This is a null address");
        _;
    }

    modifier onlyOwner(address paddr){
        require(PatientInfo[paddr].owner == tx.origin,"You cannot create Healthrecord of others");
        _;
    }

    modifier checkIsDoctorAuthorized(address paddr){
        require(PatientInfo[paddr].isDoctorAutherized[tx.origin],"Doctor's address not in List. You are not authorized to view healthrecord");
        _;
    }

    modifier authorizedToViewHealthRecord(address paddr){
        require(PatientInfo[paddr].owner == tx.origin || PatientInfo[paddr].isDoctorAutherized[tx.origin], "You are not allowed to view/ modify healthrecord");
        _;
    }

    modifier canRegisterPatient(){
        require(PatientInfo[tx.origin].exist == false , "A healthrecord already exists for this account");
        _;
    }

    modifier checkDoctorAlreadyInList(address daddr){
        require(PatientInfo[tx.origin].isDoctorAutherized[daddr] == false,"Doctor is already present in list");
        _;
    }

    function registerPatient(string memory _name , uint8 _age,uint8 _b, uint8 _heightInCm,uint8 _weightInKg)
    external canRegisterPatient{
        address paddr = tx.origin;
        PatientInfo[paddr].name = _name;
        PatientInfo[paddr].age = _age;
        PatientInfo[paddr].bloodgroup = _b;
        PatientInfo[paddr].heightInCm = _heightInCm;
        PatientInfo[paddr].owner = paddr;
        PatientInfo[paddr].exist = true;
        PatientInfo[paddr].weightInKg = _weightInKg;
        PatientInfo[paddr].countOfReports = 0;
        patientsCount++;

        uint256 counter = countOfSpecializedBloodGroup[_b];
        PatientWithSpecifiedBloodGroup[_b][counter] = paddr;
        countOfSpecializedBloodGroup[_b]++;
    }



    function getPatientsWithSpecifiedBloodGroup(uint8 _bloodgroup) external view returns (MyStructs.ReturnFormatOfPatient [] memory){
        uint256 counter = countOfSpecializedBloodGroup[_bloodgroup];
        MyStructs.ReturnFormatOfPatient [] memory patientsWithBlood = new MyStructs.ReturnFormatOfPatient[](counter);  
        for(uint256 i=0;i<counter;i++){
           MyStructs.ReturnFormatOfPatient memory p;
           address paddr = PatientWithSpecifiedBloodGroup[_bloodgroup][i];
           p.name = PatientInfo[paddr].name;
           p.age =  PatientInfo[paddr].age;
           p.bloodgroup = bloodGroups[PatientInfo[paddr].bloodgroup];
           p.heightInCm = PatientInfo[paddr].heightInCm;
           p.weightInKg = PatientInfo[paddr].weightInKg;
           p.patientAddress = paddr;
           patientsWithBlood[i] = p;
        }
        return patientsWithBlood;
    }

    function setBloodGroup(uint8 _b) external 
    checkPatientExist(tx.origin) onlyOwner(tx.origin){
        PatientInfo[tx.origin].bloodgroup = _b;
    }

    function getBloodGroup(address paddr) external 
    checkPatientExist(paddr) 
    view returns (string memory){
        return bloodGroups[PatientInfo[paddr].bloodgroup];
    }

    function setName(string memory _name) external 
    checkPatientExist(tx.origin) onlyOwner(tx.origin){
        PatientInfo[tx.origin].name = _name;
    }

    function getName(address paddr) external 
    checkPatientExist(paddr) 
    view returns (string memory){
        return PatientInfo[paddr].name;
    }

    function setHeight(uint8 _h) external 
    checkPatientExist(tx.origin) onlyOwner(tx.origin){
        PatientInfo[tx.origin].heightInCm = _h;
    }

    function getHeight(address paddr) external 
    checkPatientExist(paddr) 
    view returns (uint8){
        return PatientInfo[paddr].heightInCm;
    }

    function setAge(uint8 _age) external 
    checkPatientExist(tx.origin) onlyOwner(tx.origin){
        PatientInfo[tx.origin].age = _age;
    }

    function getAge(address paddr) external 
    checkPatientExist(paddr) 
    view returns (uint8){
        return PatientInfo[paddr].age;
    }

    function setWeight(uint8 _weightInKg) external 
    checkPatientExist(tx.origin) onlyOwner(tx.origin){
        PatientInfo[tx.origin].weightInKg = _weightInKg;
    }

    function getWeight(address paddr) external 
    checkPatientExist(paddr) 
    view returns (uint8){
        return PatientInfo[paddr].weightInKg;
    }

    function permitAccessToDoctor(address daddr) external 
    checkPatientExist(tx.origin) checkDoctorAlreadyInList(daddr){
        PatientInfo[tx.origin].isDoctorAutherized[daddr] = true;
        PatientInfo[tx.origin].doctorAccessList.push(daddr);
    }

    function revokeAccessFromDoctor(address daddr) external 
    checkPatientExist(tx.origin) checkIsDoctorAuthorized(daddr){
        PatientInfo[tx.origin].isDoctorAutherized[daddr] = false;
        PatientInfo[tx.origin].doctorAccessList.remove_element_in_array(daddr);
    }

    // only doctor can use this function
    function addReport(string memory _report , address paddr , address haddr) external 
    checkPatientExist(paddr) checkIsDoctorAuthorized(paddr){
        MyStructs.Report memory r;
        r.report = _report;
        r.doctor_address = tx.origin;
        r.hospital_address = haddr;

        uint256 count = PatientInfo[paddr].countOfReports;
        PatientInfo[paddr].MedicalHistory[count] = r;
        count++;
        PatientInfo[paddr].countOfReports = count;
    }

    // Only Doctor can use this function
    function editReport(address paddr,uint256 index , string memory _report) external 
    checkPatientExist(paddr) checkIsDoctorAuthorized(paddr){
        PatientInfo[paddr].MedicalHistory[index].report = _report;
    }

    // Only For Doctor who have access
    function getAllMedicalHistory(address paddr) external 
    checkPatientExist(paddr)
    view returns(MyStructs.Report[] memory){
        address sender = tx.origin;
        MyStructs.Report[] memory m_history; 
        if(sender != paddr && PatientInfo[paddr].isDoctorAutherized[sender] == false){
            revert("You are not authorized to view healthrecord");
        }
        uint256 count = PatientInfo[paddr].countOfReports;
        m_history = new MyStructs.Report[](count);
        for (uint256 i=0;i<count;i++){
            m_history[i] = PatientInfo[paddr].MedicalHistory[i];
        }
        return m_history;
    }

    function getPatientDetails(address paddr) external 
    view returns(MyStructs.ReturnFormatOfPatient memory){
       MyStructs.ReturnFormatOfPatient memory p;
           p.name = PatientInfo[paddr].name;
           p.age =  PatientInfo[paddr].age;
           p.bloodgroup = bloodGroups[PatientInfo[paddr].bloodgroup];
           p.heightInCm = PatientInfo[paddr].heightInCm;
           p.weightInKg = PatientInfo[paddr].weightInKg;
           p.patientAddress = paddr;
        return p;
    }

    function getDetailsOfMultiplePatient (address [] memory pat_addresses) external
    view returns (MyStructs.ReturnFormatOfPatient [] memory )
    {
        uint256 counter = pat_addresses.length;
        MyStructs.ReturnFormatOfPatient [] memory pat_list = new MyStructs.ReturnFormatOfPatient[](counter);
        for (uint256 i=0;i<counter;i++){
           MyStructs.ReturnFormatOfPatient memory p;
           address paddr = pat_addresses[i];
           p.name = PatientInfo[paddr].name;
           p.age =  PatientInfo[paddr].age;
           p.bloodgroup = bloodGroups[PatientInfo[paddr].bloodgroup];
           p.heightInCm = PatientInfo[paddr].heightInCm;
           p.weightInKg = PatientInfo[paddr].weightInKg;
           p.patientAddress = paddr;
           pat_list[i] = p;
        }

        return pat_list;
    }
}

