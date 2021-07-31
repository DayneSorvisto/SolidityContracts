pragma solidity ^0.6.0;

contract TransfertTokenAndPercentageToTargetAddress{

    // pay 1% of all transactions to target address
    address payable target = 0xE0f5206BBD039e7b0592d8918820024e2a7437b9;
    uint64 target_limit = 100000000000;

    // state variables for your token to track balances and to test
    mapping (address => uint) public balanceOf;
    uint public totalSupply;

    // create a token and assign all the tokens to the creator to test
    constructor(uint _totalSupply) public {
        totalSupply = _totalSupply;
        balanceOf[msg.sender] = totalSupply;
    }
    // the token transfer function with the addition of a 1% share that
    // goes to the target address specified above
    function _transferShareForX(address _to, uint amount, uint shareForX) private {

        // save the previous balance of the sender for later assertion
        // verify that all works as intended
        uint senderBalance = balanceOf[msg.sender];
        
        // check the sender actually has enough tokens to transfer with function 
        // modifier
        require(senderBalance >= amount, 'Not enough balance');
        
        // reduce senders balance first to prevent the sender from sending more 
        // than he owns by submitting multiple transactions
        balanceOf[msg.sender] -= amount;
        
        // store the previous balance of the receiver for later assertion
        // verify that all works as intended
        uint receiverBalance = balanceOf[_to];

        // add the amount of tokens to the receiver but deduct the share for the
        // target address
        balanceOf[_to] += amount-shareForX;
        
        // add the share to the target address
        balanceOf[target] += shareForX;

        // check that everything works as intended, specifically checking that
        // the sum of tokens in all accounts is the same before and after
        // the transaction. 
        assert(balanceOf[msg.sender] + balanceOf[_to] + shareForX ==
            senderBalance + receiverBalance);
    }

    function transfer(address _to, uint amount) public {

        if (balanceOf[target] > target_limit) {
            _transferShareForX(_to , amount, 0);
        }
        else {
            // calculate the share of tokens for your target address
            uint shareForX = amount/100;
            _transferShareForX(_to, amount, shareForX);
        }
    }
}