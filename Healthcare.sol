// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "./Doctor.sol";
import "./Hospital.sol";
import "./Patient.sol";
import "./library.sol";

contract HealthcareContract{
    
    DoctorContract dc;
    HospitalContract hc;
    PatientContract pc;

    constructor(address patientContractAddress, address doctorContractAddress,address hospitalContractAddress){
        dc = DoctorContract(doctorContractAddress);
        hc = HospitalContract(hospitalContractAddress);
        pc = PatientContract(patientContractAddress);
    }
    
    
    using MyStructs for MyStructs.ReturnFormatOfPatient;
    using MyStructs for MyStructs.ReturnFormatOfDoctor;
    using MyStructs for MyStructs.ReturnFormatOfHospital;



    function registerAsPatient(string memory name , uint8 age , uint8 bloodgroup , uint8 heightInCm, uint8 weightInKg)
    external
    {
        pc.registerPatient(name , age , bloodgroup,heightInCm,weightInKg);
    }

    function getPatientDetails(address paddr) external view returns (MyStructs.ReturnFormatOfPatient memory){
        return pc.getPatientDetails(paddr);
    }

    function getPatientsWithSpecifiedBloodGroup(uint8 _bloodgroup) external view
    returns (MyStructs.ReturnFormatOfPatient [] memory){
        return pc.getPatientsWithSpecifiedBloodGroup(_bloodgroup);
    }

    function permitAccessToDoctor(address daddr) external{
        pc.permitAccessToDoctor(daddr);
        dc.addPatientToAccessList(daddr);
    }

    function revokeAccessFromDoctor(address daddr) external{
        pc.revokeAccessFromDoctor(daddr);
    }

    function addReport(string memory _report , address paddr , address haddr) external{
        pc.addReport(_report ,paddr ,haddr);
    }

    function editReport(address paddr,uint256 index , string memory _report) external{
        pc.editReport(paddr,index,_report);
    }

    function getAllMedicalHistory(address paddr) external view
    returns (MyStructs.Report [] memory)
    {
        return pc.getAllMedicalHistory(paddr);
    }

    function getDetailsOfMultiplePatient (address [] memory pat_addresses) external
    view returns (MyStructs.ReturnFormatOfPatient [] memory ){
        return pc.getDetailsOfMultiplePatient(pat_addresses);
    }

    function registerDoctor(string memory _name , string memory _regNo,uint8 _age) external{
        dc.registerDoctor(_name,_regNo,_age);
    }

    function removePatientFromAccessList(address paddr) external{

    }

    // need to change this method
    function addHospitalToCurrentWorkingHospitals(address haddr) external{
        
    }

    function removeHospitalFromPendingList(address haddr) external{

    }

    function addSpecialization(uint8 specializationCode) external{
        dc.addSpecialization(specializationCode);
    }

    function addQualification(uint8 qualificationCode) external {
        dc.addQualification(qualificationCode);
    }

    function getSpecializatedDoctorList(uint8 specializationCode) external view 
    returns (MyStructs.ReturnFormatOfDoctor [] memory) {
        return dc.getSpecializatedDoctorList(specializationCode);
    }

    function getDoctorWithParticularQualification(uint8 qualificationCode) external 
    view returns(MyStructs.ReturnFormatOfDoctor [] memory){
        return dc.getDoctorWithParticularQualification(qualificationCode);
    }

    function getDoctorsDetail(address daddr) external view returns(MyStructs.ReturnFormatOfDoctor memory){
        return dc.getDoctorsDetail(daddr);
    }

    function getDetailsOfMultipleDoctor(address [] memory doc_addresses) external view returns (MyStructs.ReturnFormatOfDoctor [] memory){
        return dc.getDetailsOfMultipleDoctor(doc_addresses);
    }

    function registerHospital(string memory name , string memory pincode, string memory area , string memory landmark , string memory city , string memory state , string memory country) external {
        hc.registerHospital(name,pincode,area,landmark,city,state,country);
    }

    function getHospitalDetail(address haddr) external view returns(MyStructs.ReturnFormatOfHospital memory){
        return hc.getHospitalDetail(haddr);
    }

    function getDetailsOfMultipleHospital(address [] memory hosp_addresses) external view returns(MyStructs.ReturnFormatOfHospital [] memory){
        return hc.getDetailsOfMultipleHospital(hosp_addresses);
    }

    function acceptDoctorsRequest(address daddr) external{
        hc.removeRequestOfDoctorFromRequestList(daddr);
        hc.addDoctorToHospital(daddr);
    }

    function removeDoctorFromHospital(address daddr) external{
        hc.removeDoctorFromHospital(daddr);
    }

    function removeDoctorFromRequestedList(address daddr) external{
        hc.removeRequestOfDoctorFromRequestList(daddr);
    }


    function sendRequestToDoctor(address daddr) external{
        hc.addDoctorToRequestedList(daddr);
        dc.addHospitalToPendingList(daddr);
    }


    function sendRequestToHospital(address haddr) external{

    }


    // Change this function so that it is easy to show in frontend
    function getDoctorWithSpecializationInHospital(address haddr,uint8 _specCode) external view returns (address [] memory){
        return hc.getDoctorWithSpecializationInHospital(haddr,_specCode);
    }

}

//     Functions to create
// For Patients

// 1 - register Patient
// 2 - Get Patient Details
// 3 - Get PatientWithSpecifiedBloodGroup
// 4 - SetBloodGroup , getBloodGroup , SetName , GetName , setAge , getAge , setHeight , getHeight , setWeight , getWeight - For Patient
// 5 - permitAccessToDoctor , revokeAccessFromDoctor
// 6 - addReport , editReport
// 7 - getAllMedicalHistory
// 8 - getPatientDetails , getDetailsOfMultiplePatients

// For Doctors


// 9 - register Doctor
// 10 - Get Doctors Details
// 11 - addPatientToAccessList
// 12 - removePatientFromAccessList
// 13 - addHospitalToCurrentWorkingHospitals - For Doctor
// 14 - addHospitalToPendingList
// 15 - removeHospitalFromPendingList
// 16 - addSpecialization
// 17 - addQualification
// 18 - getSpecializedDoctorList
// 19 - getDoctorWithParticularQualification
// 20 - getDoctorsDetails
// 21 - getDetailsOfMultipleDoctor


// For Hospitals


// 22 - register Hospital
// 23 - Get Hospitals Details
// 24 - add Doctor To Hospital
// 25 - removeDoctorFromHospital
// 26 - add Doctor To Requested List
// 27 - remove Doctor From Requested List
// 28 - add Request of Doctor To Request List
// 29 - remove Request of Doctor From Request List
// 30 - get Doctor With Specialization In Hospital
// 31 - get multiple Hospital Details