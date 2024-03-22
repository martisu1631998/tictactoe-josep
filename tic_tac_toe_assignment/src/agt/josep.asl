
/*

Implementation of our Tic-Tac-Toe player.

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

// Define the three possible states of each cell
available(X,Y) :- isCell(X,Y) & not mark(X,Y,_).
my_piece(X,Y) :- isCell(X,Y) & mark(X,Y,S) & symbol(S).
opponent_piece(X,Y) :- isCell(X,Y) & not available(X,Y) & not my_piece(X,Y).


// More complex rules:

// Returns true if a cell is in a winning position
horizontalWinner(X,Y) :- available(X,Y) & ((my_piece(X,Y+1) & my_piece(X,Y+2)) | 
									       (my_piece(X,Y-1) & my_piece(X,Y-2)) |
										   (my_piece(X,Y+1) & my_piece(X,Y-1))).

verticalWinner(X,Y) :- available(X,Y) & ((my_piece(X+1,Y) & my_piece(X+2,Y)) | 
									     (my_piece(X-1,Y) & my_piece(X-2,Y)) |
										 (my_piece(X+1,Y) & my_piece(X-1,Y))).

rightDiagonalWinner(X,Y) :- available(X,Y) & ((my_piece(X+1, Y+1) & my_piece(X+2, Y+2)) |
											  (my_piece(X-1, Y-1) & my_piece(X+1, Y+1)) |
											  (my_piece(X-1, Y-1) & my_piece(X-2, Y-2))).

leftDiagonalWinner(X,Y) :- available(X,Y) & ((my_piece(X+1, Y-1) & my_piece(X+2, Y-2)) |
											 (my_piece(X-1, Y+1) & my_piece(X+1, Y+1)) |
											 (my_piece(X-1, Y+1) & my_piece(X-2, Y+2))).

winner(X,Y) :- horizontalWinner | verticalWinner | rightDiagonalWinner | leftDiagonalWinner.


// Returns true if a cell is in a position to avoid a loss
horizontalSaver(X,Y) :- available(X,Y) & ((opponent_piece(X,Y+1) & opponent_piece(X,Y+2)) | 
									      (opponent_piece(X,Y-1) & opponent_piece(X,Y-2)) |
										  (opponent_piece(X,Y+1) & opponent_piece(X,Y-1))).

verticalSaver(X,Y) :- available(X,Y) & ((opponent_piece(X+1,Y) & opponent_piece(X+2,Y)) | 
									    (opponent_piece(X-1,Y) & opponent_piece(X-2,Y)) |
										(opponent_piece(X+1,Y) & opponent_piece(X-1,Y))).

rightDiagonalSaver(X,Y) :- available(X,Y) & ((opponent_piece(X+1, Y+1) & opponent_piece(X+2, Y+2)) |
											 (opponent_piece(X-1, Y-1) & opponent_piece(X+1, Y+1)) |
											 (opponent_piece(X-1, Y-1) & opponent_piece(X-2, Y-2))).

leftDiagonalSaver(X,Y) :- available(X,Y) & ((opponent_piece(X+1, Y-1) & opponent_piece(X+2, Y-2)) |
											(opponent_piece(X-1, Y+1) & opponent_piece(X+1, Y+1)) |
											(opponent_piece(X-1, Y+1) & opponent_piece(X-2, Y+2))).

saver(X,Y) :- horizontalSaver | verticalSaver | rightDiagonalSaver | leftDiagonalSaver.


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

+round(Z) : next <- .findall(available(X,Y),available(X,Y),AvailableCells);
						L = .length(AvailableCells);
						N = math.floor(math.random(L));
						.nth(N,AvailableCells,available(A,B));
						 play(A,B).
*/
+round(Z) : next <- .findall(winner(X,Y), winner(X,Y), possibleWins);
					N_winners = .length(possibleWins);
					if (N_winners > 0) {.nth(0, possibleWins, winner(A,B)); play(A,B)}
					else {!playSafe}.

+!playSafe <- .findall(saver(X,Y), saver(X,Y), possibleSaves);
			  N_savers = .length(possibleSaves);
			  if (N_savers > 0) {.nth(0, possibleSaves, saver(A,B)); play(A,B)}
			  else {!playMiddle}.
					
+!playMiddle <- if (available(1,1)){
					play(1,1);
				.print("Middle was available!")}
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

+end <- confirmEnd.
