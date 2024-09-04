// SPDX-License-Identifier: WXP

pragma solidity ^0.8.19;

contract SimpleERC20 {

    uint private totalSupply;

    // Create {} for address and balance
    struct listOfData{
        string _name;
        address _address;
        uint256 _balance;
    }

    struct Ledger {
        address recipient;
        address sender;
        uint256 ammount;
    }

    mapping(string => listOfData) private data;
    Ledger[] internal ledgers; // Store all transaction
    listOfData[] internal users; // Store all register users 

    function Register(string memory _nme, uint256 _bal) public{
        bytes32 hash = keccak256(abi.encodePacked(_nme));
        address _add = address(uint160(uint256(hash)));
        totalSupply += _bal;
        data[_nme] = listOfData(_nme, _add, _bal);
        users.push(listOfData(_nme, _add, _bal));
    }

    function User(string memory keyword) public view returns(address, uint256){
        listOfData memory info = data[keyword];
        return (info._address,info._balance);
    }

    event Transfer(string indexed from, string indexed to, uint256 amount);

    function transfer(string memory _from, string memory _to, uint256 _amount) public {
        require(data[_from]._balance >= _amount, "You have not enough coin");
        data[_from]._balance -= _amount;
        data[_to]._balance += _amount;
        ledgers.push(Ledger(data[_to]._address,data[_from]._address,_amount));
        emit Transfer(_from, _to, _amount);
    }

    //function Supply() public view returns(uint256) {
    //    return totalSupply;
    //}

    //function viewData() public view returns(listOfData[] memory){
    //    return users;
    //}

    //function viewLedger() public view returns(Ledger[] memory){
    //    return ledgers;
    //}
}
