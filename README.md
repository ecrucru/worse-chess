
# Worse Chess

> Any decent UCI chess engine will now play a worse/the worst chess move

This script is an adapter between your chess GUI and your favorite UCI engine. The engine will play the N-th best move, or simply the worst move by pushing this logic to the limits. Either its prevent your strong engine from taking advantage of your blunders, or you desperately want to be checkmated by an engine that plays the worst move.

Functionally, the script simply asks the UCI engine to analyze multiple variation lines. But instead of returning the best move, the adapter will check for an alternate line.

Technically, it works with any classic/variant UCI engine that supports the option `MultiPV` with a value strictly greater than 1. For that, it is strongly recommended to have a multi-core CPU. The "strength of the weakness" is defined through the UCI option `WorseChess_MultiPV_Limit`. The higher, the slower and the weaker.


## Install

- Install NodeJS.org
- If you compile this project yourself :
	- Run once `npm install -g coffeescript`
	- Edit `worse-chess.coffee` with Notepad to change :
		- `opt_engine` : the existing engine to be used with its full path, or a global command (like `node`, `java`...)
		- `opt_arguments` : an array of string values separated with a comma to be passed to the command line, containing the full name of the script when you use a global command for example
		- Please note that every single character `\` should be written as `\\`.
	- Run `coffee -b -c worse-chess.coffee`
- Else
	- With Notepad, edit `opt_engine` and `opt_arguments` in the officially released file `worse-chess.js` by following the above rules
- Use the command `node worse-chess.js` in your favorite chess application

Remark : most chess GUI will not accept that you choose the real engine from the UCI options of Worse Chess. Indeed the options are loaded the first time you install the script. That's why you should edit the file first as explained above.


## License

```
Worse Chess - Any decent UCI chess engine will now play a worse/the worst chess move
Copyright (C) 2018, ecrucru

	https://github.com/ecrucru/worse-chess/

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as
published by the Free Software Foundation, either version 3 of the
License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License
along with this program. If not, see <http://www.gnu.org/licenses/>.
```


## Sample games

- Human vs Worse Chess

```
[Event "Demo match"]
[Site "https://github.com/ecrucru/worse-chess/"]
[Date "2018.05.20"]
[Round "1"]
[White "ecrucru"]
[Black "Stockfish (via Worse Chess)"]
[Result "*"]

{Limit of 3}
1. e4 h6 2. Ke2 c5 3. Kf3 Nc6 4. Kg4 d5+ 5. Kh5 Nf6+ 6. Kh4 Nxe4 7. g4 e5+ 8.
Kh5 d4 9. d3 Ng3+ 10. hxg3 Be7 11. Bg5 g6+ 12. Kh4 h5 13. Rh3 Qd7 14. Qf3 e4
15. Qxf7+ Kd8 16. Nc3 Bxg5+ 17. Kxg5 Ne7 18. Kh4 exd3 19. Qf5 gxf5 20. Ne4 f4
21. Ng5 hxg4+ 22. Nh7 Ng6+ 23. Kh5 Qf5+ 24. Kh6 Ne7 25. Rh5 Qf6#
```

- Worse Chess vs Weak engine

```
[Event "Demo match"]
[Site "https://github.com/ecrucru/worse-chess/"]
[Date "2018.05.20"]
[Round "2"]
[White "Stockfish (via Worse Chess)"]
[Black "Toledo NanoChess UCI"]
[Result "*"]

{Limit of 16}
1. a4 c5 2. Nh3 d5 3. Nf4 e5 4. h3 exf4 5. Rh2 f5 6. g4 fxg4 7. b3 Qh4 8. Bg2
g3 9. c3 gxh2 10. Ra2 Qg5 11. Rc2 h1=Q+ 12. Bxh1 Qg1#
```

- Strong engine vs Worse Chess

```
[Event "Demo match"]
[Site "https://github.com/ecrucru/worse-chess/"]
[Date "2018.05.20"]
[Round "3"]
[White "Stockfish"]
[Black "Stockfish (via Worse Chess)"]
[Result "*"]

{Limit of 16}
1. e4 b5 2. d4 a5 3. Nf3 Ra7 4. Bxb5 Ra6 5. c4 Re6 6. Qe2 f6 7. Nc3 Rxe4 8.
Qxe4 h5 9. Qg6#
```

- Worse Chess vs Worse Chess

```
[Event "Demo match"]
[Site "https://github.com/ecrucru/worse-chess/"]
[Date "2018.05.20"]
[Round "4"]
[White "Stockfish (via Worse Chess)"]
[Black "Komodo (via Worse Chess)"]
[Result "*"]

{Limit of 12}
1. g3 h6 2. d3 Na6 3. h3 Rh7 4. Bd2 g6 5. a3 c5 6. Bc1 Rh8 7. a4 Qb6 8. e3 d5
9. Be2 Rh7 10. Kf1 Qc7 11. c4 h5 12. Ra3 b6 13. Bd2 Bh6 14. g4 Kf8 15. f4 Qd7
16. Kg2 Qd6 17. Qe1 Nb4 18. Qh4 a6 19. b3 Bd7 20. Qe1 Nf6 21. Kf1 a5 22. Nc3
Ke8 23. Nxd5 Rb8 24. Rh2 Rg7 25. Qc1 h4 26. Bf3 Kd8 27. Qb2 Rg8 28. Rg2 Re8 29.
Bc3 Nxg4 30. Ne2 g5 31. Ra1 Nf2 32. Rh2 Qc6 33. Nd4 Qb7 34. Nf5 Be6 35. Bf6
Bxf5 36. Rg2 g4 37. Rh2 gxf3 38. Qd2 Ra8 39. Ra3 Nbxd3 40. Bg7 Bg6 41. Ba1 Ra6
42. Qc2 e6 43. Nb4 Nxf4 44. Qc3 N4d3 45. e4 Bf4 46. Qd2 Rf8 47. Qe3 Ke8 48. Bc3
Rg8 49. Be1 Qd7 50. Bd2 Bh7 51. Na2 Qb7 52. e5 Bxh2 53. Bb4 Rg1#
```

```
[Event "Demo match"]
[Site "https://github.com/ecrucru/worse-chess/"]
[Date "2018.05.20"]
[Round "5"]
[White "Komodo (via Worse Chess)"]
[Black "Stockfish (via Worse Chess)"]
[Result "*"]

{Limit of 64. Komodo reaches the unexpected mate in any case while Stockfish
relies on the lines} 1. g4 f5 2. f3 Kf7 3. b4 Kf6 4. h3 g5 5. Rh2 Ke5 6. c3
Kf4 7. Bg2 e5 8. Kf2 Qe8 9. d3#
```

- Weak engine vs Worse Chess in a variant game

```
[Event "Demo match"]
[Site "https://github.com/ecrucru/worse-chess/"]
[Date "2018.05.20"]
[Round "6"]
[White "AntiCrux"]
[Black "Stockfish (via Worse Chess)"]
[Result "*"]
[Variant "suicide"]

1. b3 b5 2. g3 Na6 3. c4 bxc4 4. bxc4 e5 5. e3 e4 6. f3 exf3 7. Qxf3 Nb8 8.
Qxf7 Kxf7 9. a3 Bxa3 10. Nxa3 c6 11. Nh3 Kf8 12. Ng5 Qxg5 13. Bd3 Qxe3 14. Bxh7
Qxa3 15. Bxa3 Rxh7 16. Bxf8 Rxh2 17. Bxg7 Rxd2 18. Rxa7 Rxa7 19. Kxd2 Na6 20.
Bf6 Nxf6 21. Rh5 Nxh5 22. Ke2 Nxg3 23. Ke3 Nf5 24. c5 Nxe3
```
