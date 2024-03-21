
/*

Implementation of a Tic-Tac-Toe player that just plays random moves.

When the agent is started it must first perform a 'sayHello' action.
Once all agents have done this, the game or tournament starts.

Each turn the agent will observe the following percepts:

- symbol(x) or symbol(o) 
	This indicates which symbol this agent should use to mark the cells. It will be the same in every turn.

- a number of marks:  e.g. mark(0,0,x) , mark(0,1,o) ,  mark(2,2,x)
  this indicates which cells have been marked with a 'x' or an 'o'. 
  Of course, in the first turn no cell will be marked yet, so there will be no such percept.

- round(Z)
	Indicates in which round of the game we are. 
	Since this will be changing each round, it can be used by the agent as a trigger to start the plan to determine
	its next move.

Furthermore, the agent may also observe the following:

- next 
	This means that it is this agent's turn.
  
- winner(x) or winner(o)
	If the game is over and did not end in a draw. Indicates which player won.
	
- end 
	If the game is finished.
	
- After observing 'end' the agent must perform the action 'confirmEnd'.

To mark a cell, use the 'play' action. For example if you perform the action play(1,1). 
Then the cell with coordinates (1,1) will be marked with your symbol. 
This action will fail if that cell is already marked.

*/



/* Initial beliefs and rules */


// First, define a 'cell' to be a pair of numbers, between 0 and 2. i.e. (0,0) , (0,1), (0,2) ... (2,2).

isCoordinate(0).
isCoordinate(1).
isCoordinate(2).

isCell(X,Y) :- isCoordinate(X) & isCoordinate(Y).

/* A cell is 'available' if it does not contain a mark.*/
available(X,Y) :- isCell(X,Y) & not mark(X,Y,_).
my_piece(X,Y) :- isCell(X,Y) & mark(X,Y, symbol(S)). //myPlayer's piece is in a cell with its symbol assigned at the beginning
opponent_piece(X, Y) :- not available(X,Y) & not my_piece(X,Y). //opponent's piece is in a cell and is not myPlayer's piece

//Define diagonals
isDiagonal() :- isCell(0,0) & isCell(0,1) & isCell(0,2).

started.


/* Plans */

/* When the agent is started, perform the 'sayHello' action. */
+started <- sayHello.

/* Whenever it is my turn, play a random move. Specifically:
	- find all available cells and put them in a list called AvailableCells.
	- Get the length L of that list.
	- pick a random integer N between 0 and L.
	- pick the N-th cell of the list, and store its coordinates in the variables A and B.
	- mark that cell by performing the action play(A,B).
*/
+round(Z) : next <- .findall(available(X,Y), available(X,Y), AvailableCells);
	// !playToWin;
	// !playToNotLose;
	!playMiddle.
	
!playToWin : 

// !playToNotLose : 

+!playMiddle <- if (available(1,1)){play(1,1);
				}//.print("Middle was available!")}
				else {!playCorner}.

+!playCorner <- if (available(0,0)) {play(0,0)} else{
	if (available(2,0)) {play(2,0)} else{
	if (available(0,2)) {play(0,2)} else{
	if (available(2,2)) {play(2,2)} else{
	!playEdge
	}}}}.

+!playEdge <- if (available(1,0)) {play(1,0)} else{
	if (available(0,1)) {play(0,1)} else{
	if (available(2,1)) {play(2,1)} else{
	if (available(1,2)) {play(1,2)} }}}.
						 
/* If I am the winner, then print "I won!"  */
+winner(S) : symbol(S) <- .print("I won!").

+end <- confirmEnd.
