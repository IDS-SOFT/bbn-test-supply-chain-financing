
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract SupplyChainFinancingContract {
    IERC20 public financingToken; // The token used for financing

    struct Invoice {
        address supplier;
        address buyer;
        uint256 amount;
        bool financed;
    }

    Invoice[] public invoices;
    uint256 public totalInvoices;

    mapping(address => uint256) public supplierInvoiceCount;

    event InvoiceFinanced(address indexed supplier, address indexed buyer, uint256 invoiceId, uint256 amount);
    event CheckBalance(uint amount);

    constructor(address _financingToken) {
        financingToken = IERC20(_financingToken);
    }

    modifier onlyOwner() {
        require(owner == msg.sender, "Only owner can call this function");
        _;
    }

    function createInvoice(address _buyer, uint256 _amount) external {
        require(_buyer != address(0), "Invalid address");
        require(_amount > 0, "Invoice amount must be greater than zero");

        Invoice memory newInvoice = Invoice({
            supplier: msg.sender,
            buyer: _buyer,
            amount: _amount,
            financed: false
        });

        invoices.push(newInvoice);
        supplierInvoiceCount[msg.sender]++;
        totalInvoices++;
    }

    function financeInvoice(uint256 _invoiceId) external {
        require(_invoiceId < invoices.length, "Invalid invoice ID");
        Invoice storage invoice = invoices[_invoiceId];

        require(msg.sender == invoice.buyer, "Only the buyer can finance the invoice");
        require(!invoice.financed, "Invoice is already financed");

        financingToken.transferFrom(msg.sender, invoice.supplier, invoice.amount);
        invoice.financed = true;

        emit InvoiceFinanced(invoice.supplier, msg.sender, _invoiceId, invoice.amount);
    }

    function getBalance(address user_account) external returns (uint){
       uint user_bal = user_account.balance;
       emit CheckBalance(user_bal);
       return (user_bal);
    }
}
