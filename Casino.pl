
%----------------------------------------------------------------------------------------------------
%   Name:     Abish Jha
%   Project:  Casino
%   Class:    OPL
%   Date:     December 11, 2018
%----------------------------------------------------------------------------------------------------



%----------------------------------------------------------------------------------------------------
%   Predicate Name: casino
%   Purpose: To kick off the game and handle data loading for resumed games.
%   Parameters: default parameter
%   Local Variables: choice
%----------------------------------------------------------------------------------------------------
casino(_):- write("Welcome to Casino!"),nl,
    write("Would you like to load a game?(y/n) "),
    read(Choice),
    validateYesNoChoice(Choice),
    startGame(Choice).
casino(_):- casino(_).

%----------------------------------------------------------------------------------------------------
%   Predicate Name: startGame
%   Purpose: To either start a new tournament or load a file for the tournament.
%   Parameters: choices for whether to start a new game (y) or load (n)
%   Local Variables: None
%----------------------------------------------------------------------------------------------------
startGame(y):- getTournamentFromFile(Tournament),
    resumeTournament(Tournament).
startGame(n):- newTournament(_).

%----------------------------------------------------------------------------------------------------
%   Predicate Name: newTournament
%   Purpose: determine the first player and start a new Tournament.
%   Parameters: default parameter
%   Local Variables: none
%----------------------------------------------------------------------------------------------------
newTournament(_) :-
    determineFirstPlayer(NextPlayer),
    % Round count is 1 because it starts from 1, everything else are default values for respective parameters
    playTournament(1, 0, 0, NextPlayer).

%----------------------------------------------------------------------------------------------------
%   Predicate Name: getTournamentFromFile
%   Purpose: To read the tournament from a serialized file.
%   Parameters: Tournament, to store the tournament to return after loading
%   Local Variables: FileName to get the input from user and Content to fetch the content of the file
%----------------------------------------------------------------------------------------------------
getTournamentFromFile(Tournament):-
    write("Enter the filename to load: "),
    read(FileName),
    with_output_to(atom(AFileName), write(FileName)),
    string_concat("./", AFileName, FullPath),
    exists_file(FullPath),
    open(FullPath,read,File),
    read(File, Content),
    close(File),
    Tournament = Content,
    write("tournament loaded from "), write(FullPath), nl, nl.
getTournamentFromFile(Tournament):- getTournamentFromFile(NewTournament),
    Tournament = NewTournament.

%----------------------------------------------------------------------------------------------------
%   Predicate Name: playTournament
%   Purpose: To play the tournament.
%   Parameters: RoundCount, HumanScore, CompScore, and NextPlayer which is equal to the last capturer for the last round
%   Local Variables: GameState which is passed to resumeTournament
%----------------------------------------------------------------------------------------------------
%if the torunament has ended, stop
playTournament(_, HumanScore, ComputerScore, NextPlayer):- checkIfTournamentEnded(HumanScore, ComputerScore).
%if not generate a new round and continue
playTournament(RoundCount, HumanScore, ComputerScore, NextPlayer):-
    generateNewRound(RoundCount, HumanScore, ComputerScore, NextPlayer, GameState),
    resumeTournament(GameState).

%----------------------------------------------------------------------------------------------------
%   Predicate Name: resumeTournament
%   Purpose: To resume the tournament with the given gamestate.
%   Parameters: gamestate, current game state
%   Local Variables: Choice for save and quit choice, CScore, HScore for computer and human round score,
%                    NewHumanScore and NewComputerScore for the updated human and computer tournament score
%----------------------------------------------------------------------------------------------------
resumeTournament(GameState) :- askIfSaveAndQuit(Choice),
    write("===================="), nl,
    write("starting round..."), nl,
    write("===================="), nl, nl,
    runRound(GameState, [CScore,HScore|_], Choice),
    GameState = [RoundCount, ComputerScore, _, _, HumanScore, _, _, _, _, LastCapturer, _, _],
    NewHumanScore is HumanScore + HScore,
    NewCompScore is ComputerScore+CScore,
    NewRoundCount is RoundCount+1,
    playTournament(NewRoundCount, NewHumanScore, NewCompScore, LastCapturer).

%----------------------------------------------------------------------------------------------------
%   Predicate Name: checkIfTournamentEnded
%   Purpose: To check if the tournament ended.
%   Parameters: human score and computer score
%   Local Variables: None
%----------------------------------------------------------------------------------------------------
% both are 21 or over but human score is greater
checkIfTournamentEnded(HumanScore, CompScore) :- HumanScore >= 21,
    CompScore >= 21,
    HumanScore > CompScore,
    write("Human won the tournament with the score of "),write(HumanScore),nl,
    write("Computer had a score of "),write(CompScore),nl.
% both are 21 or over but computer score is greater
checkIfTournamentEnded(HumanScore, CompScore) :- HumanScore >= 21,
    CompScore >= 21,
    CompScore > HumanScore,
    write("Computer won the tournament with the score of "),write(CompScore),nl,
    write("Human had a score of "),write(HumanScore),nl.
% both are 21 or over and its a tie
checkIfTournamentEnded(HumanScore, CompScore) :- HumanScore >= 21,
    CompScore >= 21,
    write("It is a tie with a score of "), write(CompScore),nl.
% human score is 21 or over
checkIfTournamentEnded(HumanScore, CompScore) :- HumanScore >= 21,
    write("Human won the tournament with the score of "),write(HumanScore),nl,
    write("Computer had a score of "),write(CompScore),nl.
% computer score is 21 or over
checkIfTournamentEnded(HumanScore, CompScore) :- CompScore >= 21,
    write("Computer won the tournament with the score of "),write(CompScore),nl,
    write("Human had a score of "),write(HumanScore),nl.


%----------------------------------------------------------------------------------------------------
%   Predicate Name: generateNewRound
%   Purpose: To generate a new fresh round.
%   Parameters: RoundCount, HumanScore, ComputerScore, NextPlayer and GameState to store the game in
%   Local Variables: UnshuffledDeck - initial unshuffled deck, Deck - shuffled deck, 
%                    NewDeck - after giving four to human, NewerDeck - after giving four to computer, and 
%                    NewestDeck - after giving four to table
%----------------------------------------------------------------------------------------------------
generateNewRound(RoundCount, HumanScore, ComputerScore, NextPlayer, GameState) :- 
    UnshuffledDeck = ['ca', 'c2', 'c3', 'c4', 'c5', 'c6', 'c7', 'c8', 'c9', 'cx', 'cj', 'cq', 'ck', 'sa', 's2', 's3', 's4', 's5', 's6', 's7', 's8', 's9', 'sx', 'sj', 'sq', 'sk', 'da', 'd2', 'd3', 'd4', 'd5', 'd6', 'd7', 'd8', 'd9', 'dx', 'dj', 'dq', 'dk', 'ha', 'h2', 'h3', 'h4', 'h5', 'h6', 'h7', 'h8', 'h9', 'hx', 'hj', 'hq', 'hk'],
    random_permutation(UnshuffledDeck, Deck),
    giveFour(Deck, HumanHand, NewDeck),
    giveFour(NewDeck, ComputerHand, NewerDeck),
    giveFour(NewerDeck, Table, NewestDeck),
    GameState = [RoundCount, ComputerScore, ComputerHand, [], HumanScore, HumanHand, [], Table, [], NextPlayer, NewestDeck, NextPlayer].

%----------------------------------------------------------------------------------------------------
%   Predicate Name: determineFirstPlayer
%   Purpose: To determine the first player for the round by coin toss
%   Parameters: NextPlayer
%   Local Variables: R - the result of the coin toss, N - the user input choice
%----------------------------------------------------------------------------------------------------
determineFirstPlayer(NextPlayer):- random_between(0, 1, R),
    nl, write("coin toss..."), nl,
    write("choose head (1) or tail (0) : "),
    read(N),
    N = R,
    write("congrats the guess was right. human is the first player..."), nl, nl,
    NextPlayer = human.
determineFirstPlayer(NextPlayer):- write("sorry the guess was wrong. computer is the first player..."), nl, nl,
    NextPlayer = computer.

%----------------------------------------------------------------------------------------------------
%   Predicate Name: runRound
%   Purpose: To kick off the round and run it until the round ends.
%   Parameters: current game state, new game state for return value, save and quit choice
%   Local Variables: Stream - to save the game state, NewerState - state after giving four cards to human and computer when their hand becomes empty
%----------------------------------------------------------------------------------------------------
%if the player decided to save and quit
runRound(OldGameState, OldGameState, y) :- open("./game.txt", write, Stream),
    write(Stream,OldGameState),
    write(Stream,"."),
    close(Stream),
    write("game saved to ./game.txt and quitting..."), nl,
    halt(0).
%if the round ended
runRound(OldGameState, RoundResults, _) :-
    getHumanHand(OldGameState, HumanHand),
    getComputerHand(OldGameState, ComputerHand),
    getDeck(OldGameState, Deck),
    checkIfRoundEnded(ComputerHand, HumanHand, Deck), nl,
    write("The round has ended!"), nl, nl,
    %if this function is to corrected and used, also change the first parameter for calculateRoundScore to EndGameState from OldGameState
    %giveLooseCardsToLastCapturer(OldGameState, EndGameState),
    calculateRoundScore(OldGameState, ComputerScore, HumanScore),
    RoundResults = [ComputerScore, HumanScore].
%continue round with usual flow
runRound(OldGameState, NewGameState, n) :- 
    displayGameState(OldGameState),
    playRound(OldGameState, NewState),
    checkIfHandEmpty(NewState, NewerState),
    askIfSaveAndQuit(Choice),
    runRound(NewerState, NewestGameState, Choice),
    NewGameState = NewestGameState.

%----------------------------------------------------------------------------------------------------
%   Predicate Name: playRound
%   Purpose: To decide the next player and get the respective move.
%   Parameters: OldGameState for the current state and NewGameState for the game state after the execution of the respective move
%   Local Variables: Turn - the current turn
%----------------------------------------------------------------------------------------------------
%human player
playRound(OldGameState, NewGameState) :- getTurn(OldGameState, Turn),
    Turn = human,
    getHumanMenuAction(OldGameState, NewState),
    NewGameState = NewState.
%computer player
playRound(OldGameState, NewGameState) :- getTurn(OldGameState, Turn),
    Turn = computer,
    getComputerMove(OldGameState, NewState),
    NewGameState = NewState.

%----------------------------------------------------------------------------------------------------
%   Predicate Name: checkIfRoundEnded
%   Purpose: To check if round ended.
%   Parameters: computer hand, human hand, deck
%   Local Variables: none
%----------------------------------------------------------------------------------------------------
%human hand, computer hand, and the deck is empty
checkIfRoundEnded([], [], []).

%----------------------------------------------------------------------------------------------------
%   Predicate Name: calculateRoundScore
%   Purpose: To calculate the round score.
%   Parameters: game state, computer score and human score
%   Local Variables: HS1, CS1 - score for the most cards in pile,
%                    HS2, CS2 - score for the most spades in pile,ù
%                    HS3, CS3 - score for the player who has 10 of diamonds,
%                    HS4, CS4 - score for the player who has 2 of spades,
%                    HS5, CS5 - score for the aces in the pile,
%                    HScore, CScore - score for the round that is the addition of (HS1..HS5) for human and (CS1..CS5) for computer
%----------------------------------------------------------------------------------------------------
calculateRoundScore(GameState, ComputerScore, HumanScore):- getLastCapturer(GameState, LastCapturer),
    getHumanPile(GameState, HumanPile),
    getComputerPile(GameState, CompPile),
    write("last capturer "), write(LastCapturer), write(" got the cards remaining on the table"), nl,
    write("Human Pile: "), write(HumanPile), nl,
    write("Computer Pile: "), write(CompPile), nl, 
    nl,
    endMostCards(HumanPile, CompPile, HS1, CS1),
    endMostSpades(HumanPile, CompPile, HS2, CS2),
    end10Diamonds(HumanPile, CompPile, HS3, CS3),
    end2Spades(HumanPile, CompPile, HS4, CS4),
    endAces(HumanPile, CompPile, HS5, CS5),
    nl,
    HScore is HS1 + HS2 + HS3 + HS4 + HS5,
    CScore is CS1 + CS2 + CS3 + CS4 + CS5,
    write("Human Round Score: "),write(HScore),nl,
    write("Computer Round Score: "),write(CScore),nl,
    determineRoundWinner(CScore, HScore),
    nl,
    ComputerScore = CScore,
    HumanScore = HScore.


%----------------------------------------------------------------------------------------------------
%   Predicate Name: endMostCards
%   Purpose: check and give score for the player who has the most cards in the pile
%   Parameters: HumanPile, CompPile, HS1 for human score and CS1 for computer score
%   Local Variables: HumanLen, CompLen - the size of the respective players pile
%----------------------------------------------------------------------------------------------------
% if the lengths of both players pile is the same, no one gets any point
endMostCards(HumanPile, CompPile, HS1, CS1) :- length(HumanPile, HumanLen),
    length(CompPile, CompLen),
    write("length of comp  pile :: ") , write(CompLen),  nl,
    write("length of human pile :: ") , write(HumanLen),  nl,
    HumanLen = CompLen,
    HS1 = 0,
    CS1 = 0.
% human has a bigger pile
endMostCards(HumanPile, CompPile, HS1, CS1) :- length(HumanPile, HumanLen),
    length(CompPile, CompLen),
    HumanLen > CompLen,
    HS1 = 3,
    CS1 = 0.
% computer has a bigger pile
endMostCards(HumanPile, CompPile, HS1, CS1) :- HS1 = 0,
    CS1 = 3.


%----------------------------------------------------------------------------------------------------
%   Predicate Name: endMostSpades
%   Purpose: check and give score for the player who has the most spades in the pile
%   Parameters: HumanPile, CompPile, HS2 for human score and CS2 for computer score
%   Local Variables: HSpade, CSpade - the number of spades in the respective players pile
%----------------------------------------------------------------------------------------------------
endMostSpades(HumanPile, CompPile, HS2, CS2) :- 
    getSpadeCount(CompPile, 0, CSpade),
    getSpadeCount(HumanPile, 0, HSpade),
    write("number of spade in comp  pile :: ") , write(CSpade),  nl,
    write("number of spade in human pile :: ") , write(HSpade),  nl,
    checkSpadeCount(HSpade, CSpade, HScore, CScore),
    HS2 = HScore,
    CS2 = CScore.

%----------------------------------------------------------------------------------------------------
%   Predicate Name: getSpadeCount
%   Purpose: count the number of spades in a players pile
%   Parameters: Pile, Count - the count of spades after every iteration, and Score - the total number of spades
%   Local Variables: Counter which is Count + 1
%----------------------------------------------------------------------------------------------------
getSpadeCount([], Count, Score) :- Score = Count.
getSpadeCount([X | Pile], Count, Score) :- isSpade(X),
    Counter is Count + 1,
    getSpadeCount(Pile, Counter, Score).
getSpadeCount([X | Pile], Count, Score) :- getSpadeCount(Pile, Count, Score).

%----------------------------------------------------------------------------------------------------
%   Predicate Name: isSpade
%   Purpose: check if the given card is of suite spade
%   Parameters: Card
%   Local Variables: CardList - a list whose first element is the suite and the second is the value of the passed in card,
%                    Suite - the suite of the card
%----------------------------------------------------------------------------------------------------
isSpade(Card) :- string_to_list(Card, Cardlist),
    nth0(0, Cardlist, Suite),
    Suite = 115.

%----------------------------------------------------------------------------------------------------
%   Predicate Name: checkSpadeCount
%   Purpose: check and give score for the player who has the most spades in the pile
%   Parameters: HSpade, CSpade - for the number of spades in the respective players pile, 
%               HScore for human score and CScore for computer score
%   Local Variables: HSpade, CSpade - the number of spades in the respective players pile
%----------------------------------------------------------------------------------------------------
checkSpadeCount(HSpade, CSpade, HScore, CScore) :- HSpade = CSpade,
    HScore = 0,
    CScore = 0.
checkSpadeCount(HSpade, CSpade, HScore, CScore) :- HSpade > CSpade,
    HScore = 1,
    CScore = 0.
checkSpadeCount(HSpade, CSpade, HScore, CScore) :- HSpade < CSpade,
    HScore = 0,
    CScore = 1.


%----------------------------------------------------------------------------------------------------
%   Predicate Name: end10Diamonds
%   Purpose: check and give score for the player who has the 10 of diamonds in the pile
%   Parameters: HumanPile, CompPile, HS3 for human score and CS3 for computer score
%   Local Variables: none
%----------------------------------------------------------------------------------------------------
% check for 10 of diamonds -- 'dx'
end10Diamonds(HumanPile, CompPile, HS3, CS3) :- has10Diamonds(HumanPile),
    write("human has 10 of diamonds (dx)"), nl,
    HS3 = 2,
    CS3 = 0.
end10Diamonds(HumanPile, CompPile, HS3, CS3) :- has10Diamonds(CompPile),
    write("computer has 10 of diamonds (dx)"), nl,
    HS3 = 0,
    CS3 = 2.
% should never reach here but if it does, this does not let the program crash
end10Diamonds(HumanPile, CompPile, HS3, CS3) :- HS3 = 0, CS3 = 0.

%----------------------------------------------------------------------------------------------------
%   Predicate Name: has10Diamonds
%   Purpose: check if the given pile has 10 of diamonds
%   Parameters: Pile
%   Local Variables: X - the head of the pile list
%----------------------------------------------------------------------------------------------------
has10Diamonds([X | Pile]) :- is10Diamonds(X).
has10Diamonds([X | Pile]) :- has10Diamonds(Pile).

%----------------------------------------------------------------------------------------------------
%   Predicate Name: is10Diamonds
%   Purpose: check if the given card is 10 of diamonds
%   Parameters: Card
%   Local Variables: CardList - a list whose first element is the suite and the second is the value of the passed in card,
%                    Suite - the suite of the card, Value - the value of the card
%----------------------------------------------------------------------------------------------------
is10Diamonds(Card) :- string_to_list(Card, Cardlist),
    nth0(0, Cardlist, Suite),
    Suite = 100,
    nth0(1, Cardlist, Value),
    Value = 120.


%----------------------------------------------------------------------------------------------------
%   Predicate Name: end2Spades
%   Purpose: check and give score for the player who has the 2 of spades in the pile
%   Parameters: HumanPile, CompPile, HS4 for human score and CS4 for computer score
%   Local Variables: none
%----------------------------------------------------------------------------------------------------
end2Spades(HumanPile, CompPile, HS4, CS4) :- has2Spades(HumanPile),
    write("human has 2 of spades (s2)"), nl,
    HS4 = 1,
    CS4 = 0.
end2Spades(HumanPile, CompPile, HS4, CS4) :- has2Spades(CompPile),
    write("computer has 2 of spades (s2)"), nl,
    HS4 = 0,
    CS4 = 1.
% should never reach here but if it does, this does not let the program crash
end2Spades(HumanPile, CompPile, HS4, CS4) :- HS4 = 0, CS4 = 0.

%----------------------------------------------------------------------------------------------------
%   Predicate Name: has2Spades
%   Purpose: check if the given pile has 2 of spades
%   Parameters: Pile
%   Local Variables: X - the head of the pile list
%----------------------------------------------------------------------------------------------------
has2Spades([X | Pile]) :- is2Spades(X).
has2Spades([X | Pile]) :- has2Spades(Pile).

%----------------------------------------------------------------------------------------------------
%   Predicate Name: is2Spades
%   Purpose: check if the given card is 2 of spades
%   Parameters: Card
%   Local Variables: CardList - a list whose first element is the suite and the second is the value of the passed in card,
%                    Suite - the suite of the card, Value - the value of the card
%----------------------------------------------------------------------------------------------------
is2Spades(Card) :- string_to_list(Card, Cardlist),
    nth0(0, Cardlist, Suite),
    Suite = 115,
    nth0(1, Cardlist, Value),
    Value = 50.


%----------------------------------------------------------------------------------------------------
%   Predicate Name: endAces
%   Purpose: count number of aces in the players pile and give a point per ace
%   Parameters: HumanPile, CompPile, HS5, CS5 - the score of human and computer respectively
%   Local Variables: CAce, HAce - number of ace in the respective players pile
%----------------------------------------------------------------------------------------------------
endAces(HumanPile, CompPile, HS5, CS5) :- 
    getAceCount(CompPile, 0, CAce),
    getAceCount(HumanPile, 0, HAce),
    write("number of ace in human pile :: "), write(HAce), nl, 
    write("number of ace in comp  pile :: "), write(CAce), nl, 
    HS5 = HAce,
    CS5 = CAce.

%----------------------------------------------------------------------------------------------------
%   Predicate Name: getAceCount
%   Purpose: count number of aces in the players pile
%   Parameters: Pile, Count - number of ace that have been encountered, Score - the total number of aces in the pile
%   Local Variables: X - the head of the pile list i.e. the card currently being dealt with, Counter is Count + 1
%----------------------------------------------------------------------------------------------------
getAceCount([], Count, Score) :- Score = Count.
getAceCount([X | Pile], Count, Score) :- isAce(X),
    Counter is Count + 1,
    getAceCount(Pile, Counter, Score).
getAceCount([X | Pile], Count, Score) :- getAceCount(Pile, Count, Score).

%----------------------------------------------------------------------------------------------------
%   Predicate Name: isAce
%   Purpose: check if the given card is of suite ace
%   Parameters: Card
%   Local Variables: CardList - a list whose first element is the suite and the second is the value of the passed in card,
%                    Value - the value of the card
%----------------------------------------------------------------------------------------------------
isAce(Card) :- string_to_list(Card, Cardlist),
    nth0(1, Cardlist, Value),
    Value = 97.


%----------------------------------------------------------------------------------------------------
%   Predicate Name: determineRoundWinner
%   Purpose: To determine the winner of the round.
%   Parameters: CScore, HScore
%   Local Variables: none
%----------------------------------------------------------------------------------------------------
% its a tie
determineRoundWinner(CScore, HScore):- CScore = HScore,
    write("--- The round ended as a draw! ---"),nl.
% computer score is greater than human score
determineRoundWinner(CScore, HScore):- CScore > HScore,
    write("--- Computer wins the round ---"),nl.
% human score is greater than computer score
determineRoundWinner(CScore, HScore):- HScore > CScore,
    write("---Human wins the round ---"),nl.


%----------------------------------------------------------------------------------------------------
%   Predicate Name: getHumanMenuAction
%   Purpose: To display human game menu and call the appropriate action depending on the choice.
%   Parameters: GameState, NewGameState
%   Local Variables: Choice - selection from the menu
%----------------------------------------------------------------------------------------------------
getHumanMenuAction(GameState, NewState) :-
    nl, write("----------------------------------------------------------"),nl,
	write("Please select one of the following options: "),nl,
	write("1. Make a move"),nl,
	write("2. Ask for help"),nl,
	write("3. Exit the game"),nl,
	write("----------------------------------------------------------"),nl,
    read(Choice),
    number(Choice),
    getHumanChoiceAction(Choice, GameState, NewGameState),
    NewState = NewGameState.
getHumanMenuAction(GameState, NewState) :-  write("Invalid menu choice, try again!"),
    getHumanMenuAction(GameState, NewGameState),
    NewState = NewGameState.

%----------------------------------------------------------------------------------------------------
%   Predicate Name: getHumanChoiceAction
%   Purpose: To get the human move based on the selected menu option.
%   Parameters: menu choice, GameState, NewState
%   Local Variables: HandCard - the hand card for the move, Action - action to be done, LooseCards - loosecards for the move
%----------------------------------------------------------------------------------------------------
getHumanChoiceAction(1, GameState, NewState):-
    getHumanMove(GameState, HandCard, Action, LooseCards),
    % no matter what action is selected, only do trail
    nl, write("=========="), nl,
    write("since trail is the only thing working, trailing the selected hand card :: "), write(HandCard), nl,
    write("=========="), nl,
    makeMove(GameState, NewGameState, HandCard, t, LooseCards),
    NewState = NewGameState, nl.
getHumanChoiceAction(1, GameState, NewState):-
    getHumanChoiceAction(1, GameState, NewestState),
    NewState = NewestState, nl.
% if human asks for a hint
getHumanChoiceAction(2, GameState, NewState) :-
    getHint(GameState, HandCard, Action, LooseCards),
    getHumanMenuAction(GameState, NewGameState),
    NewState = NewGameState.
getHumanChoiceAction(3, _, _) :- write("exiting game..."), nl,
    halt(0).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% getHumanMove -- hand card, action, and loose cards    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%----------------------------------------------------------------------------------------------------
%   Predicate Name: getHumanMove
%   Purpose: To get the details for the human move, and then check the move
%   Parameters: GameState, HandCard, Action, LooseCards
%   Local Variables: none
%----------------------------------------------------------------------------------------------------
getHumanMove(GameState, HandCard, Action, LooseCards) :-
    getAction(Action),
    getHandCard(GameState, HandCard),
    % so we do not ask for loose cards if the action is trail
    getLooseCards(GameState, LooseCards, Action),
    checkMove(GameState, HandCard, Action, LooseCards).
getHumanMove(GameState, HandCard, Action, LooseCards) :-
    nl, write("Invalid move. Please try again!"), nl,
    getHumanMove(GameState, NewHandCard, NewAction, NewLooseCards),
    HandCard = NewHandCard,
    Action = NewAction,
    LooseCards = NewLooseCards.


%----------------------------------------------------------------------------------------------------
% get and validate action
%----------------------------------------------------------------------------------------------------
%   Predicate Name: getAction
%   Purpose: To print the menu and get action for the move
%   Parameters: Action
%   Local Variables: Choice
%----------------------------------------------------------------------------------------------------
getAction(Action) :-
    nl, write("what action do you want to perform? (only type the character in the brackets) "), nl,
    write("(b) build"), nl, write("(e) extend build"), nl, write("(m) multi build"), nl, write("(c) capture"), nl, write("(t) trail"), nl,
    read(Choice),
    checkActionChoice(Choice),
    Action = Choice.
getAction(Action) :-
    write("Invalid action choice, try again! (only trail is working...)"), nl, nl,
    getAction(NewAction),
    Action = NewAction.

%----------------------------------------------------------------------------------------------------
%   Predicate Name: checkAction - facts and not predicates
%   Purpose: To check if the user selected a valid action from the menu
%   Parameters: none
%   Local Variables: none
%----------------------------------------------------------------------------------------------------
checkActionChoice(b).
checkActionChoice(e).
checkActionChoice(m).
checkActionChoice(c).
checkActionChoice(t).
%----------------------------------------------------------------------------------------------------


%----------------------------------------------------------------------------------------------------
% get and validate hand card
%----------------------------------------------------------------------------------------------------
%   Predicate Name: getHandCard
%   Purpose: To print the menu and get the hand card for the move
%   Parameters: GameState, HandCard
%   Local Variables: Choice
%----------------------------------------------------------------------------------------------------
getHandCard(GameState, HandCard):-
    getHumanHand(GameState, Hand),
    nl, write("hand cards: "), write(Hand), nl,
    write("choose hand card (type as is displayed): "),
    read(Choice),
    member(Choice, Hand),
    HandCard = Choice.
getHandCard(GameState, HandCard):-
    write("Invalid hand card choice, try again!"), nl,
    getHandCard(GameState, NewHandCard),
    HandCard = NewHandCard.
%----------------------------------------------------------------------------------------------------


%----------------------------------------------------------------------------------------------------
% get and validate loose cards
%----------------------------------------------------------------------------------------------------
%   Predicate Name: getLooseCards
%   Purpose: To print the menu and get the loose card(s) for the move
%   Parameters: GameState, LooseCards, Action
%   Local Variables: Choice
%----------------------------------------------------------------------------------------------------
% if the action is t (trail), no need to select loose cards
getLooseCards(_, LooseCards, t) :- LooseCards = [].
getLooseCards(GameState, LooseCards, Action) :-
    getTable(GameState, Table),
    nl, write("choose loose cards (type as is on new line for each)"), nl,
    write("loose cards: "), write(Table), nl,
    getLooseCard(Choice),
    checkLooseCards(Choice, Table),
    LooseCards = Choice.
getLooseCards(GameState, LooseCards, Action):-
    write("Invalid loose card(s) choice, try again!"), nl,
    getLooseCards(GameState, NewLooseCards, Action),
    LooseCards = NewLooseCards.

%----------------------------------------------------------------------------------------------------
%   Predicate Name: getLooseCard
%   Purpose: To get input from the user for each loose card\build on a separate line, enter 's' to stop
%   Parameters: ChoiceList
%   Local Variables: none
%----------------------------------------------------------------------------------------------------
% to get individual loose cards from the table.  input 's' to stop
getLooseCard([LooseCard|ChoiceList]) :-
    write('enter loose card (s to stop):'), read(LooseCard),
    dif(LooseCard, s),
    getLooseCard(ChoiceList).
getLooseCard(_).

%----------------------------------------------------------------------------------------------------
%   Predicate Name: checkLooseCards
%   Purpose: check if all the input loose cards are present on the table
%   Parameters: LooseCardsList, Table
%   Local Variables: none
%----------------------------------------------------------------------------------------------------
checkLooseCards([], _).
checkLooseCards([H|T], Table) :-
    member(H, Table),
    checkLooseCards(T, Table).
checkLooseCards(_, _) :- false.
%----------------------------------------------------------------------------------------------------


%----------------------------------------------------------------------------------------------------
%   Predicate Name: getHint
%   Purpose: To get a hint for the best possible move
%   Parameters: GameState, HandCard, Action, LooseCards
%   Local Variables: none
%----------------------------------------------------------------------------------------------------
getHint(GameState, HandCard, Action, LooseCards) :-
    getTurn(GameState, Turn),
    Turn = human,
    getHumanHand(GameState, Hand),
    Action = t, [HandCard|_] = Hand, LooseCards = [],
    write("the human can trail --> "), write(HandCard), nl, nl.
getHint(GameState, HandCard, Action, LooseCards) :-
    getTurn(GameState, Turn),
    Turn = computer,
    getComputerHand(GameState, Hand),
    Action = t, [HandCard|_] = Hand, LooseCards = [],
    write("the computer can trail --> "), write(HandCard), nl, nl.


%----------------------------------------------------------------------------------------------------
%   Predicate Name: getComputerMove
%   Purpose: To get a move for the computer and execute it
%   Parameters: OldGameState, NewState
%   Local Variables: HandCard, Action, LooseCards - for the move to execute
%----------------------------------------------------------------------------------------------------
% function called when its the computer player's turn
getComputerMove(OldGameState, NewState) :-
    getHint(OldGameState, HandCard, Action, LooseCards),
    write("=========="), nl,
    write("computer is making the above move..."), nl,
    write("=========="), nl,
    makeMove(OldGameState, NewGameState, HandCard, Action, LooseCards),
    NewState = NewGameState, nl.

%----------------------------------------------------------------------------------------------------
%   Predicate Name: checkMove
%   Purpose: To check if a move is valid
%   Parameters: GameState, HandCard, Action, LooseCards
%   Local Variables: none
%----------------------------------------------------------------------------------------------------
checkMove(GameState, HandCard, Action, LooseCards).

%----------------------------------------------------------------------------------------------------
%   Predicate Name: makeMove
%   Purpose: To execute the input move and update the game state accordingly
%   Parameters: GameState - current game state, NewGameState - state after execution of move,
%               HandCard - hand card for the move, Action - one of five possible moves, LooseCards - loose cards for the move
%   Local Variables: Choice
%----------------------------------------------------------------------------------------------------
% can fill later to make other moves possible... for now, the only action that can be called is t which is hardcoded in getHumanChoiceAction/3.
makeMove(GameState, NewGameState, HandCard, b, LooseCards).

makeMove(GameState, NewGameState, HandCard, e, LooseCards).

makeMove(GameState, NewGameState, HandCard, m, LooseCards).

makeMove(GameState, NewGameState, HandCard, c, LooseCards).

makeMove([RoundCount, ComputerScore, ComputerHand, ComputerPile, HumanScore, HumanHand, HumanPile, Table, BuildOwner, LastCapturer, Deck, NextPlayer], NewGameState, HandCard, t, _) :- 
    NextPlayer = human,
    getHumanHand(GameState, HumanHand),
    delete(HumanHand, HandCard, NewHumanHand),
    getTable(GameState, Table),
    append(Table, [HandCard], NewTable),
    NewGameState = [RoundCount, ComputerScore, ComputerHand, ComputerPile, HumanScore, NewHumanHand, HumanPile, NewTable, BuildOwner, LastCapturer, Deck, computer].

makeMove([RoundCount, ComputerScore, ComputerHand, ComputerPile, HumanScore, HumanHand, HumanPile, Table, BuildOwner, LastCapturer, Deck, NextPlayer], NewGameState, HandCard, t, _) :- 
    NextPlayer = computer,
    getComputerHand(GameState, ComputerHand),
    delete(ComputerHand, HandCard, NewComputerHand),
    getTable(GameState, Table),
    append(Table, [HandCard], NewTable),
    NewGameState = [RoundCount, ComputerScore, NewComputerHand, ComputerPile, HumanScore, HumanHand, HumanPile, NewTable, BuildOwner, LastCapturer, Deck, human].



%----------------------------------------------------------------------------------------------------
% getters for variables from gameState
getComputerScore(GameState, Score):-nth0(1,GameState,Score).

getComputerHand(GameState, Hand):-nth0(2,GameState,Hand).

getComputerPile(GameState, Pile):-nth0(3,GameState,Pile).

getHumanScore(GameState, Score):-nth0(4,GameState,Score).

getHumanHand(GameState, Hand ):-nth0(5,GameState,Hand).

getHumanPile(GameState, Pile ):-nth0(6,GameState,Pile).

getTable(GameState, Table):-nth0(7,GameState,Table).

getBuildOwner(GameState, Owner):-nth0(8,GameState,Owner).

getLastCapturer(GameState, Capturer):-nth0(9,GameState,Capturer).

getDeck(GameState, Passed):-nth0(10,GameState,Passed).

getTurn(GameState, Turn):-nth0(11,GameState,Turn).
%----------------------------------------------------------------------------------------------------


%----------------------------------------------------------------------------------------------------
%   Predicate Name: askIfSaveAndQuit
%   Purpose: To ask if the user wants to save and quit
%   Parameters: Answer to return the user choice
%   Local Variables: Choice - the users input
%----------------------------------------------------------------------------------------------------
askIfSaveAndQuit(Answer):- write("Would you like to save and quit? (y/n) "),
    read(Choice), nl,
    validateYesNoChoice(Choice),
    Answer = Choice.
askIfSaveAndQuit(Answer):- askIfSaveAndQuit(NewAnswer),
    Answer = NewAnswer.

%----------------------------------------------------------------------------------------------------
%   Predicate Name: validateYesNoChoice
%   Purpose: To validate yes or no choice.
%----------------------------------------------------------------------------------------------------
validateYesNoChoice(y).
validateYesNoChoice(n).

%----------------------------------------------------------------------------------------------------
%   Predicate Name: displayGameState
%   Purpose: To display the game state
%----------------------------------------------------------------------------------------------------
displayGameState(GameState) :-
    getComputerHand(GameState, ComputerHand),
    getHumanHand(GameState, HumanHand),
    getTable(GameState, Table),
    getBuildOwner(GameState, BuildOwner),
    getTurn(GameState, Turn),
    getHumanPile(GameState, HumanPile),
    getComputerPile(GameState, ComputerPile),
    getDeck(GameState, Deck),
    getComputerScore(GameState, ComputerScore),
    getHumanScore(GameState, HumanScore),

    write("----------------------------------------------------------"),
    nl,
    write("Table: "), write(Table), nl,
    write("Build Owner: "), write(BuildOwner), nl,
    write("----------------------------------------------------------"),
    nl,
    write("Computer Hand: "), write(ComputerHand), nl,
    write("Human Hand: "), write(HumanHand), nl,
    write("Turn: "), write(Turn), nl,
    write("----------------------------------------------------------"),
    nl,
    write("Computer Pile: "), write(ComputerPile), nl,
    write("Human Pile: "), write(HumanPile), nl,
    write("Deck: "), write(Deck), nl,
    write("Tournament Score => "), 
    write("Human : "), write(HumanScore), tab(4), 
    write("Computer : "), write(ComputerScore), nl,
    write("----------------------------------------------------------"), nl.


%----------------------------------------------------------------------------------------------------
%   Predicate Name: checkIfHandEmpty
%   Purpose: if the deck is not empty and both the players hand is empty, give four cards to the human and four to the computer
%   Parameters: OldGameState, NewGameState
%   Local Variables: NewDeck, NewerDeck - the deck state after giving four to human and then computer player respectively
%----------------------------------------------------------------------------------------------------
checkIfHandEmpty([RoundCount, ComputerScore, ComputerHand, ComputerPile, HumanScore, HumanHand, HumanPile, Table, BuildOwner, LastCapturer, Deck, NextPlayer], NewState) :-
    \+ (Deck = []),
    HumanHand = [],
    ComputerHand = [],
    write("=========="), nl,
    write("since both human and computer hand is empty, we give four cards to each..."), nl,
    write("=========="), nl, nl,
    giveFour(Deck, NewHumanHand, NewDeck),
    giveFour(NewDeck, NewComputerHand, NewerDeck),
    NewState = [RoundCount, ComputerScore, NewComputerHand, ComputerPile, HumanScore, NewHumanHand, HumanPile, Table, BuildOwner, LastCapturer, NewerDeck, NextPlayer].
% there are cards in the players hand
checkIfHandEmpty([RoundCount, ComputerScore, ComputerHand, ComputerPile, HumanScore, HumanHand, HumanPile, Table, BuildOwner, LastCapturer, Deck, NextPlayer], NewState) :-
    NewState = [RoundCount, ComputerScore, ComputerHand, ComputerPile, HumanScore, HumanHand, HumanPile, Table, BuildOwner, LastCapturer, Deck, NextPlayer].


%----------------------------------------------------------------------------------------------------
%   Predicate Name: giveFour
%   Purpose: To give four cards from the deck to the passed in pile
%   Parameters: Deck, Hand - the list with the four added cards, NewDeck - the new state of the deck
%   Local Variables: Elem0..Elem3 - the four cards being given to the input hand
%----------------------------------------------------------------------------------------------------
giveFour(Deck, Hand, NewDeck) :-
    nth0(0, Deck, Elem0),
    nth0(1, Deck, Elem1),
    nth0(2, Deck, Elem2),
    nth0(3, Deck, Elem3),
    Hand = [Elem0, Elem1, Elem2, Elem3],
    subtract(Deck, Hand, NewDeck).


%%%%%%%%%%%% NOTE:: function is not working for nested lists i.e. build representation.
%----------------------------------------------------------------------------------------------------
%   Predicate Name: giveLooseCardsToLastCapturer
%   Purpose: Give the loose cards to the player who made the last capture at the end of the round
%   Parameters: OldGameState, NewGameState
%   Local Variables: LooseCardList - the list of loose cards after parsing the builds on the table
%----------------------------------------------------------------------------------------------------
% add loose cards to the player who made the last capture
giveLooseCardsToLastCapturer([RoundCount, ComputerScore, ComputerHand, ComputerPile, HumanScore, HumanHand, HumanPile, Table, BuildOwner, LastCapturer, Deck, NextPlayer], EndGameState) :- LastCapturer = human,
    getLooseCardsAsList(Table, LooseCardList),
    write("loose card list :: "), write(LooseCardList), nl,
    append(HumanPile, LooseCardList, NewHumanPile),
    EndState = [RoundCount, ComputerScore, ComputerHand, ComputerPile, HumanScore, HumanHand, NewHumanPile, [], [], LastCapturer, Deck, human].
giveLooseCardsToLastCapturer([RoundCount, ComputerScore, ComputerHand, ComputerPile, HumanScore, HumanHand, HumanPile, Table, BuildOwner, LastCapturer, Deck, NextPlayer], EndGameState) :- LastCapturer = computer,
    getLooseCardsAsList(Table, LooseCardList),
    write("loose card list :: "), write(LooseCardList), nl,
    append(ComputerPile, LooseCardList, NewComputerPile),
    EndState = [RoundCount, ComputerScore, ComputerHand, NewComputerPile, HumanScore, HumanHand, HumanPile, [], [], LastCapturer, Deck, computer].
% should not reach here, but if it does, restore the game state and continue
giveLooseCardsToLastCapturer(OldGameState, EndGameState) :- write("problem with giving loose cards to last capturer. skipping"), nl,
    EndGameState = OldGameState.

%----------------------------------------------------------------------------------------------------
%   Predicate Name: getLooseCardsAsList
%   Purpose: convert the input multi dimensional list into a flat list with all the original cards 
%   Parameters: Cards, CardList
%   Local Variables: CardSingleList - make a flat list out of the cards
%----------------------------------------------------------------------------------------------------
% the incoming cards parameter is a list that represents the cards with the builds
getLooseCardsAsList(Cards, CardList) :- makeFlatList(Cards, CardSingleList),
    write("cards as single list :: "), write(CardSingleList), nl,
    atomic_list_concat(CardSingleList, ',', CardsString),
    split_string(CardsString, "[],", "[], ", NewCardList),
    CardList = NewCardList.

%----------------------------------------------------------------------------------------------------
%   Predicate Name: makeFlatList
%   Purpose: convert a multidimensional list into a single dimensional list with the original elements
%   Parameters: InList, OutList
%   Local Variables: X - the head of the inlist i.e. the element being examined
%----------------------------------------------------------------------------------------------------
% for single elements
makeFlatList([], OutList) :- 
    write("reached here empty "), write(OutList), nl.
makeFlatList([X | InList], OutList) :- 
    \+ (is_list(X)),
    write("reached here not list "), write(X), nl,
    append(OutList, [X], NewList),
    OutList = NewList,
    makeFlatList(InList, OutList).
% for list elements
makeFlatList([X | InList], OutList) :- write("reached here list "), write(X), nl, 
    makeFlatList(X, NewOutList),
    OutList = NewOutList,
    makeFlatList(InList, OutList).


%----------------------------------------------------------------------------------------------------
%   Predicate Name: printList
%   Purpose: prints the list passed as input with every element on a new line
%   Parameters: List - the list to print
%   Local Variables: X - the head of the inlist i.e. the element being printed
%----------------------------------------------------------------------------------------------------
printlist([]).
printlist([X|List]) :-
    write("printed:: "), write(X),nl,
    printlist(List).
printlist(_).  % just to make sure it doesnt crash the program if this function is called on something other than a list
