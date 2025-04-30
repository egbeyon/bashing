# Overview
This is a tic-tac-toe game, built with flask python web framework. The data of the game (moves and winner) is stored, archived and can be mailed to anyone.

# Play the game
- You can play it on your browser by cloning the repo and running this on your terminal:
```bash
cd bashing/log_n_alert
pip install flask
flask run
```

- Open your web browser and go to http://127.0.0.1:5000/

- When the game ends, a log file containing the moves made and the eventual winner of the game is generated.

# Logs and alert
The process_log.sh file, which can be run with `./process_log.sh`, is supposed to archive and mail the logs to specified emails (change the recipient emails), if smtp server is configured.