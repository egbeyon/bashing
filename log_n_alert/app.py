from flask import Flask, render_template, request, redirect, url_for
import logging
from datetime import datetime

app = Flask(__name__)
logging.basicConfig(filename='tic_tac_toe.log', level=logging.INFO,
                    format='%(asctime)s - %(levelname)s - %(message)s')

def check_winner(board):
    """Checks if there's a winner on the board."""
    lines = [
        board[0:3], board[3:6], board[6:9],  # Rows
        board[0:9:3], board[1:9:3], board[2:9:3],  # Columns
        board[0:9:4], board[2:7:2]  # Diagonals
    ]
    for line in lines:
        if line[0] == line[1] == line[2] != ' ':
            return line[0]
    return None

def is_board_full(board):
    """Checks if the board is full."""
    return ' ' not in board

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/play', methods=['GET', 'POST'])
def play():
    board = request.args.getlist('board')
    current_player = request.args.get('player', 'X')
    game_over = request.args.get('game_over', 'false')

    if not board:
        board = [' '] * 9

    if request.method == 'POST' and game_over == 'false':
        position = int(request.form['position'])
        if board[position] == ' ':
            board[position] = current_player
            winner = check_winner(board)
            if winner:
                logging.info(f"Game Over - Winner: {winner}, Board: {board}")
                return render_template('play.html', board=board, winner=winner, current_player=current_player, game_over='true')
            elif is_board_full(board):
                logging.info(f"Game Over - Draw, Board: {board}")
                return render_template('play.html', board=board, winner='Draw', current_player=current_player, game_over='true')
            else:
                next_player = 'O' if current_player == 'X' else 'X'
                return redirect(url_for('play', board=board, player=next_player))

    return render_template('play.html', board=board, current_player=current_player, game_over=game_over)

@app.route('/reset')
def reset():
    return redirect(url_for('play'))

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)