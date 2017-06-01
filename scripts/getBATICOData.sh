#!/bin/sh
# ----------------------------------------------------------------------------------------------
# Extrating transaction data from the BAT ICO
#
# Enjoy. (c) BokkyPooBah / Bok Consulting Pty Ltd 2017. The MIT Licence.
# ----------------------------------------------------------------------------------------------

geth attach << EOF | grep "RESULT: " | sed "s/RESULT: //"
// geth attach << EOF

var icoAddress = "0x0d8775f648430679a709e98d2b0cb6250d2887ef";
var tokenABI = [{"constant":true,"inputs":[],"name":"batFundDeposit","outputs":[{"name":"","type":"address"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"name","outputs":[{"name":"","type":"string"}],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"_spender","type":"address"},{"name":"_value","type":"uint256"}],"name":"approve","outputs":[{"name":"success","type":"bool"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"totalSupply","outputs":[{"name":"","type":"uint256"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"batFund","outputs":[{"name":"","type":"uint256"}],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"_from","type":"address"},{"name":"_to","type":"address"},{"name":"_value","type":"uint256"}],"name":"transferFrom","outputs":[{"name":"success","type":"bool"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"decimals","outputs":[{"name":"","type":"uint256"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"tokenExchangeRate","outputs":[{"name":"","type":"uint256"}],"payable":false,"type":"function"},{"constant":false,"inputs":[],"name":"finalize","outputs":[],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"version","outputs":[{"name":"","type":"string"}],"payable":false,"type":"function"},{"constant":false,"inputs":[],"name":"refund","outputs":[],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"tokenCreationCap","outputs":[{"name":"","type":"uint256"}],"payable":false,"type":"function"},{"constant":true,"inputs":[{"name":"_owner","type":"address"}],"name":"balanceOf","outputs":[{"name":"balance","type":"uint256"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"isFinalized","outputs":[{"name":"","type":"bool"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"fundingEndBlock","outputs":[{"name":"","type":"uint256"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"symbol","outputs":[{"name":"","type":"string"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"ethFundDeposit","outputs":[{"name":"","type":"address"}],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"_to","type":"address"},{"name":"_value","type":"uint256"}],"name":"transfer","outputs":[{"name":"success","type":"bool"}],"payable":false,"type":"function"},{"constant":false,"inputs":[],"name":"createTokens","outputs":[],"payable":true,"type":"function"},{"constant":true,"inputs":[],"name":"tokenCreationMin","outputs":[{"name":"","type":"uint256"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"fundingStartBlock","outputs":[{"name":"","type":"uint256"}],"payable":false,"type":"function"},{"constant":true,"inputs":[{"name":"_owner","type":"address"},{"name":"_spender","type":"address"}],"name":"allowance","outputs":[{"name":"remaining","type":"uint256"}],"payable":false,"type":"function"},{"inputs":[{"name":"_ethFundDeposit","type":"address"},{"name":"_batFundDeposit","type":"address"},{"name":"_fundingStartBlock","type":"uint256"},{"name":"_fundingEndBlock","type":"uint256"}],"payable":false,"type":"constructor"},{"anonymous":false,"inputs":[{"indexed":true,"name":"_to","type":"address"},{"indexed":false,"name":"_value","type":"uint256"}],"name":"LogRefund","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"name":"_to","type":"address"},{"indexed":false,"name":"_value","type":"uint256"}],"name":"CreateBAT","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"name":"_from","type":"address"},{"indexed":true,"name":"_to","type":"address"},{"indexed":false,"name":"_value","type":"uint256"}],"name":"Transfer","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"name":"_owner","type":"address"},{"indexed":true,"name":"_spender","type":"address"},{"indexed":false,"name":"_value","type":"uint256"}],"name":"Approval","type":"event"}];
var token = web3.eth.contract(tokenABI).at(icoAddress);

var icoFirstTxBlock = 3798640;
var icoLastTxBlock = parseInt(icoFirstTxBlock) + 500;
var totalEthers = new BigNumber(0);
var totalTokens = new BigNumber(0);

console.log("RESULT: Account\tBlock\tTxIdx\t#\tEthers\tSumEthers\tTokens\tSumTokens\tTimestamp\tDateTime\tTxHash");

function getEtherData() {
  var count = 0;
  for (var i = icoFirstTxBlock; i <= icoLastTxBlock; i++) {
    var block = eth.getBlock(i, true);
    var timestamp = block.timestamp;
    var time = new Date(timestamp * 1000);
    if (block != null && block.transactions != null) {
      block.transactions.forEach( function(e) {
        console.log("DEBUG: " + JSON.stringify(e));
        var status = debug.traceTransaction(e.hash);
        var txOk = true;
        if (status.structLogs.length > 0) {
          if (status.structLogs[status.structLogs.length-1].error) {
            txOk = false;
          }
        }
        if (e.to == icoAddress && txOk && "0xb4427263" == e.input) {
          count++;
          var ethers = web3.fromWei(e.value, "ether");
          totalEthers = totalEthers.add(ethers);
          var tokenBalancePrev = token.balanceOf(e.from, parseInt(e.blockNumber) - 1).div(1e18);
          var tokenBalance = token.balanceOf(e.from, e.blockNumber).div(1e18).minus(tokenBalancePrev);
          totalTokens = totalTokens.add(tokenBalance);
          console.log("RESULT: " + e.from + "\t" + e.blockNumber + "\t" + e.transactionIndex + "\t" + count + "\t" + ethers + "\t" + 
            totalEthers + "\t" + tokenBalance + "\t" + totalTokens + "\t" + timestamp + "\t" + time.toUTCString() + "\t" + e.hash);
        }
      });
    }
  }
}

getEtherData();

EOF
