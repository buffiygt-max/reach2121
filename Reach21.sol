// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

contract Reach21 {
    // Game states tracking
    enum GameStatus { Waiting, Active, Finished }
    
    // Variables stored on the blockchain
    address public player1;
    address public player2;
    address public turnOwner;
    uint8 public currentSum;
    uint8 public target;
    GameStatus public status;
    
    // Tracks player win counts persistently
    mapping(address => uint) public wins;

    // Events to update your future HTML frontend
    event GameStarted(address p1, uint8 target);
    event PlayerJoined(address p2);
    event MoveMade(address player, uint8 amount, uint8 newSum);
    event GameFinished(address winner);

    // Creates a new match
    function createGame(uint8 _target) public {
        require(status == GameStatus.Waiting || status == GameStatus.Finished, "Game is currently active");
        player1 = msg.sender;
        player2 = address(0);
        target = _target;
        currentSum = 0;
        status = GameStatus.Waiting;
        emit GameStarted(msg.sender, _target);
    }

    // Allows a second wallet to enter the match
    function joinGame() public {
        require(status == GameStatus.Waiting, "No game waiting");
        require(msg.sender != player1, "Player 1 cannot join their own game");
        player2 = msg.sender;
        status = GameStatus.Active;
        turnOwner = player1; // Player 1 goes first
        emit PlayerJoined(msg.sender);
    }

    // Processes a player's turn
    function makeMove(uint8 amount) public {
        require(status == GameStatus.Active, "Game is not active");
        require(msg.sender == turnOwner, "It is not your turn");
        require(amount >= 1 && amount <= 3, "You can only add 1, 2, or 3");
        require(currentSum + amount <= target, "Move exceeds target");

        currentSum += amount;
        emit MoveMade(msg.sender, amount, currentSum);

        if (currentSum == target) {
            wins[msg.sender] += 1;
            status = GameStatus.Finished;
            emit GameFinished(msg.sender);
        } else {
            // Switch turns
            if (msg.sender == player1) {
                turnOwner = player2;
            } else {
                turnOwner = player1;
            }
        }
    }

    // Returns current game state for the UI
    function getGame() public view returns (address, address, address, uint8, uint8, GameStatus) {
        return (player1, player2, turnOwner, currentSum, target, status);
    }
}