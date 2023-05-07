// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "./library.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract HospitalContract{

    struct Hospital{
        bool exist;
        string name;
        MyStructs.Address addressOfHospital;
        
        address [] doctorsWorkingInHospital;
        mapping(address => bool) isDoctorWorkingInHospital;

        address [] requestedDoctorList;
        mapping(address => bool) isDoctorInRequestedDoctorList;
        
        address [] requestFromDoctorsToJoin;
        mapping(address => bool ) isDoctorInRequestFromDoctorsToJoin;
        
        mapping(uint8 => mapping(uint256=> address)) doctorWithSpecializationInHospital;
        mapping(uint8 => uint256) countOfSpecializatedDoctorInHospital;

    }

    using Helpers for address[];
    using MyStructs for MyStructs.ReturnFormatOfHospital;
    using MyStructs for MyStructs.Address;

    mapping(address => Hospital) hospitalInfo;
    uint256 countOfHospitals = 0;

    modifier checkHospitalExists(address haddr){
        require(hospitalInfo[haddr].exist , "Hospital Doesnot Exists");
        _;
    }

    modifier checkHospitalAlreadyRegistered(address haddr){
        require(hospitalInfo[haddr].exist == false, "Hospital already registed with this public key hash");
        _;
    }

    modifier checkDoctorAlreadyWorkingInHospital(address haddr,address daddr){
        require(hospitalInfo[haddr].isDoctorWorkingInHospital[daddr]==false , "Doctor already working in this hospital");
        _;
    }

    modifier checkIfDoctorAlreadyInRequestList(address haddr , address daddr){
        require(hospitalInfo[haddr].isDoctorInRequestedDoctorList[daddr]==false, "Doctor is already present requested list");
        _;
    }

    modifier checkIfDoctorAlreadyInRequestFromDoctorList(address haddr , address daddr){
        require(hospitalInfo[haddr].isDoctorInRequestFromDoctorsToJoin[daddr]==false, "Your have already send request to hospital");
        _;
    }

    function registerHospital(string memory name , string memory pincode, string memory area , string memory landmark , string memory city , string memory state , string memory country) external 
    checkHospitalAlreadyRegistered(tx.origin){
        address haddr = tx.origin;
        hospitalInfo[haddr].name = name;
        MyStructs.Address memory _address;
        _address.pincode = pincode;
        _address.area = area;
        _address.landMark = landmark;
        _address.city = city;
        _address.state = state;
        _address.country = country;
        hospitalInfo[haddr].addressOfHospital = _address;
        hospitalInfo[haddr].exist = true;
        countOfHospitals++;
    }

    function getHospitalDetail(address haddr) external view returns(MyStructs.ReturnFormatOfHospital memory){
        MyStructs.ReturnFormatOfHospital memory h;
        h.name = hospitalInfo[haddr].name;
        h.addressOfHospital = hospitalInfo[haddr].addressOfHospital;
        h.doctorsWorkingInHospital = hospitalInfo[haddr].doctorsWorkingInHospital;
        return h;
    }

    function getDetailsOfMultipleHospital(address [] memory hosp_addresses) external view returns(MyStructs.ReturnFormatOfHospital [] memory){

        uint256 counter = hosp_addresses.length;
        MyStructs.ReturnFormatOfHospital [] memory hosp_list = new MyStructs.ReturnFormatOfHospital[](counter);
        for(uint256 i=0;i<counter;i++){
            MyStructs.ReturnFormatOfHospital memory h;
           address haddr = hosp_addresses[i];
            h.name = hospitalInfo[haddr].name;
            h.addressOfHospital = hospitalInfo[haddr].addressOfHospital;
            h.doctorsWorkingInHospital = hospitalInfo[haddr].doctorsWorkingInHospital;
            hosp_list[i] = h;
        } 

        return hosp_list;
    }

    function addDoctorToHospital(address daddr) external 
    checkHospitalExists(tx.origin) checkDoctorAlreadyWorkingInHospital(tx.origin,daddr)
    {
        address haddr = tx.origin;
        hospitalInfo[haddr].doctorsWorkingInHospital.push(daddr);
        hospitalInfo[haddr].isDoctorWorkingInHospital[daddr] = true;
    }

    function removeDoctorFromHospital(address daddr) external
    checkHospitalExists(tx.origin) 
    {
        address haddr = tx.origin;
        require(hospitalInfo[haddr].isDoctorWorkingInHospital[daddr]==true , "Doctor is not working in this hospital");
        hospitalInfo[haddr].doctorsWorkingInHospital.remove_element_in_array(daddr);
        hospitalInfo[haddr].isDoctorWorkingInHospital[daddr] = false;
    }
    

    function addDoctorToRequestedList(address daddr) external 
    checkHospitalExists(tx.origin) checkIfDoctorAlreadyInRequestList(tx.origin , daddr){
        address haddr = tx.origin;
        hospitalInfo[haddr].requestedDoctorList.push(daddr);
        hospitalInfo[haddr].isDoctorInRequestedDoctorList[daddr] = true;
    }

    function removeDoctorFromRequestedList(address daddr) external
    checkHospitalExists(tx.origin)
    {
        address haddr = tx.origin;
        require(hospitalInfo[haddr].isDoctorInRequestedDoctorList[daddr], "Doctor is not present requested list");
        hospitalInfo[haddr].requestedDoctorList.remove_element_in_array(daddr);
        hospitalInfo[haddr].isDoctorInRequestedDoctorList[daddr] = false;
    }

    // used by doctors
    function addRequestOfDoctorToRequestList(address haddr) external 
    checkHospitalExists(haddr) checkIfDoctorAlreadyInRequestList(haddr,tx.origin){
        address daddr = tx.origin;
        hospitalInfo[haddr].requestFromDoctorsToJoin.push(daddr);
        hospitalInfo[haddr].isDoctorInRequestFromDoctorsToJoin[daddr] = true;
    }

    // hospital will call this and can remove the doctor from its access list
    function removeRequestOfDoctorFromRequestList(address daddr) external
    checkHospitalExists(tx.origin)
    {
        address haddr = tx.origin;
        require(hospitalInfo[haddr].isDoctorInRequestFromDoctorsToJoin[daddr],"Doctor is not present in the list");
        hospitalInfo[haddr].requestFromDoctorsToJoin.remove_element_in_array(daddr);
        hospitalInfo[haddr].isDoctorInRequestFromDoctorsToJoin[daddr] = false;
    }

    // this message can be used by doctor , patient and hospital
    function getDoctorWithSpecializationInHospital(address haddr,uint8 _specCode) external view
    checkHospitalExists(haddr) returns (address [] memory)
    {
        uint256 counter = hospitalInfo[haddr].countOfSpecializatedDoctorInHospital[_specCode];
        address [] memory doctors_with_specialization_in_hospitals = new address[](counter);
        for(uint256 i=0;i<counter;i++){
            doctors_with_specialization_in_hospitals[i] = hospitalInfo[haddr].doctorWithSpecializationInHospital[_specCode][i];
        }

        return doctors_with_specialization_in_hospitals;
    }



}