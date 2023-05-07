// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

// Doctor contract needs Patients contract address and also hospitals contract address.

import "./library.sol";

contract DoctorContract{
    struct Doctor{
        string name;
        string registrationNumber;
        address [] currentWorkingHospitals;
        uint8 age;
        address [] pendingRequestFromHospitals;
        mapping(address => bool ) isHospitalInPendingRequest;
        uint8[] qualifications;
        uint8[] specializations;
        address [] patientAccessList;
        mapping(address => bool) isPatient_in_accessList;
        address owner;
        bool exist;
    }

    struct ReturnFormatOfDoctor{
        string doctorName;
        string registrationNumber;
        address [] currentWorkingHospitals;
        address doctorAddress;
    }

    struct hospitalDetails{
        address haddr;
        string name;
    }

    using Helpers for address[];

    mapping(address => Doctor) DoctorInfo;
    uint256 countOfDoctors = 0;

    // and counterOfSpecializedDoctor counts doctor with a particular specialization.
    mapping(uint8 => mapping(uint256 => address)) FilterWithSpecialization;
    mapping(uint8 => uint256) counterOfSpecializedDoctor;


    // Filter a doctor with qualification
    mapping(uint8 => mapping(uint256 => address)) FilterDoctorWithQualification;
    mapping(uint8 => uint256) counterOfQualDoctor;


    modifier checkDoctorRegistered(address daddr){
        require(DoctorInfo[daddr].exist == false, "Doctor is already registered with this address");
        _;
    }

    modifier checkPatientNotInList(address paddr){
        require(DoctorInfo[tx.origin].isPatient_in_accessList[paddr] == false,"Patient already in access list");
        _;
    }

    modifier checkPatientInList(address paddr){
        require(DoctorInfo[tx.origin].isPatient_in_accessList[paddr] == true , "Patient not is list");
        _;
    }

    modifier checkHospitalNotInPendingList(address haddr){
        require(DoctorInfo[tx.origin].isHospitalInPendingRequest[haddr],"Hospital not in pending list");
        _;
    }

    modifier checkHospitalInPendingList(address haddr){
        require(DoctorInfo[tx.origin].isHospitalInPendingRequest[haddr]==false,"Hospital already in pending list");
        _;
    }

    function registerDoctor(string memory _name , string memory _regNo,uint8 _age) external checkDoctorRegistered(msg.sender){
        address sender = tx.origin;
        DoctorInfo[sender].name = _name;
        DoctorInfo[sender].registrationNumber = _regNo;
        DoctorInfo[sender].age = _age;
        DoctorInfo[sender].exist = true;
        DoctorInfo[sender].owner = sender;
        DoctorInfo[sender].specializations = new uint8[](256);
        DoctorInfo[sender].qualifications = new uint8[](256);
        countOfDoctors++;
    }

    function addPatientToAccessList(address paddr) external 
    checkDoctorRegistered(tx.origin) checkPatientNotInList(paddr){
        DoctorInfo[tx.origin].patientAccessList.push(paddr);
        DoctorInfo[tx.origin].isPatient_in_accessList[paddr] = true;
    }

    function removePatientFromAccessList(address paddr) external 
    checkDoctorRegistered(tx.origin) checkPatientInList(paddr){
        DoctorInfo[tx.origin].patientAccessList.remove_element_in_array(paddr);
        DoctorInfo[tx.origin].isPatient_in_accessList[paddr] = false;
    }

    function addHospitalToCurrentWorkingHospitals(address haddr) external 
    checkDoctorRegistered(tx.origin) checkHospitalNotInPendingList(haddr){
        address daddr = tx.origin;
        DoctorInfo[daddr].currentWorkingHospitals.push(haddr);
        DoctorInfo[daddr].pendingRequestFromHospitals.remove_element_in_array(haddr);
        DoctorInfo[daddr].isHospitalInPendingRequest[haddr] = false;
    }


    // This is called by Hospital
    function addHospitalToPendingList(address daddr) external
    checkHospitalInPendingList(tx.origin) {
        address haddr = tx.origin;
        DoctorInfo[daddr].pendingRequestFromHospitals.push(haddr);
        DoctorInfo[daddr].isHospitalInPendingRequest[haddr] = true;
    }

    // This is called by Doctor
    function removeHospitalFromPendingList(address haddr) external
    checkDoctorRegistered(tx.origin) checkHospitalNotInPendingList(haddr) {
        address daddr = tx.origin;
        DoctorInfo[daddr].pendingRequestFromHospitals.remove_element_in_array(haddr);
        DoctorInfo[daddr].isHospitalInPendingRequest[haddr] = false;
    }


    function addSpecialization(uint8 specializationCode) external 
    checkDoctorRegistered(tx.origin){
        address daddr = tx.origin;
        DoctorInfo[daddr].specializations[specializationCode] = 1;
        uint256 counter = counterOfSpecializedDoctor[specializationCode];
        FilterWithSpecialization[specializationCode][counter] = daddr;
        counter++;
        counterOfSpecializedDoctor[specializationCode] = counter;
    }

    function addQualification(uint8 qualificationCode) external 
    checkDoctorRegistered(tx.origin){
        address daddr = tx.origin;
        DoctorInfo[daddr].qualifications[qualificationCode] = 1;

        uint256 counter = counterOfQualDoctor[qualificationCode];
        FilterDoctorWithQualification[qualificationCode][counter] = daddr;
        counter++;
        counterOfQualDoctor[qualificationCode] = counter;
    }

    function getSpecializatedDoctorList(uint8 _specializationCode) external view 
    returns (ReturnFormatOfDoctor [] memory) {
        uint256 counter = counterOfSpecializedDoctor[_specializationCode];
        ReturnFormatOfDoctor[] memory specializedDoctors = new ReturnFormatOfDoctor[](counter);
        for (uint256 i=1;i<=counter;i++){
            address daddr = FilterWithSpecialization[_specializationCode][i];
            specializedDoctors[i].doctorName = DoctorInfo[daddr].name;
            specializedDoctors[i].registrationNumber = DoctorInfo[daddr].registrationNumber;
            specializedDoctors[i].currentWorkingHospitals = DoctorInfo[daddr].currentWorkingHospitals;
            specializedDoctors[i].doctorAddress = daddr;
        }
        return specializedDoctors;
    }

    function getDoctorWithParticularQualification(uint8 qualificationCode) external 
    view returns(ReturnFormatOfDoctor [] memory){
        uint256 counter = counterOfQualDoctor[qualificationCode];
        ReturnFormatOfDoctor[] memory qualifiedDoctors = new ReturnFormatOfDoctor[](counter);
        for (uint256 i=1;i<=counter;i++){
            address daddr = FilterWithSpecialization[qualificationCode][i];
            qualifiedDoctors[i].doctorName = DoctorInfo[daddr].name;
            qualifiedDoctors[i].registrationNumber = DoctorInfo[daddr].registrationNumber; 
            qualifiedDoctors[i].currentWorkingHospitals = DoctorInfo[daddr].currentWorkingHospitals;
            qualifiedDoctors[i].doctorAddress = daddr;
        }
        return qualifiedDoctors;
    }

    function getDoctorsDetail(address daddr) external view returns(ReturnFormatOfDoctor memory){
        ReturnFormatOfDoctor memory d;
        d.doctorName = DoctorInfo[daddr].name;
        d.registrationNumber = DoctorInfo[daddr].registrationNumber;
        d.currentWorkingHospitals = DoctorInfo[daddr].currentWorkingHospitals;
        d.doctorAddress = daddr;
        return d;
    }

    function getDetailsOfMultipleDoctor(address [] memory doc_addresses) external view returns (ReturnFormatOfDoctor [] memory){
        uint256 counter = doc_addresses.length;
        ReturnFormatOfDoctor [] memory doc_list = new ReturnFormatOfDoctor[](counter);
        for(uint256 i=0;i<counter;i++){
            address daddr = doc_addresses[i];
            ReturnFormatOfDoctor memory d;
            d.doctorName = DoctorInfo[daddr].name;
            d.registrationNumber = DoctorInfo[daddr].registrationNumber;
            d.currentWorkingHospitals = DoctorInfo[daddr].currentWorkingHospitals;
            d.doctorAddress = daddr;
            doc_list[i] = d;
        }

        return doc_list;
        
    }


}