pragma solidity ^0.4.2;

contract Users {

  mapping (bytes32 => address) public users;

  function register(bytes32 name){
      if(users[name]==0 && name!= ""){
          users[name] = msg.sender;
      }
  }

 function unregister(bytes32 name){
      if(users[name]== 0 && name!= ""){
          users[name] = 0x0;
      }
  }

}