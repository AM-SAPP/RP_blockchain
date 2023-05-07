// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "./Doctor.sol";
import "./Hospital.sol";
import "./Patient.sol";

contract HealthcareContract{
    
    DoctorContract dc;
    HospitalContract hc;
    PatientContract pc;

    constructor(address patientContractAddress, address doctorContractAddress,address hospitalContractAddress){
        dc = DoctorContract(doctorContractAddress);
        hc = HospitalContract(hospitalContractAddress);
        pc = PatientContract(patientContractAddress);
    }

    // Functions to create
    // 1 - register Patient
    // 2 - register Doctor
    // 3 - register Hospital
    // 4 - Get Patient Details
    // 5 - Get Doctors Details
    // 6 - Get Hospitals Details
    // 7 - 
}