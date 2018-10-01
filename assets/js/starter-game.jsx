import React from 'react';
import ReactDOM from 'react-dom';
import _ from 'lodash';

export default function game_init(root, channel) {
    ReactDOM.render(<Starter channel={channel} />, root);
}

class Starter extends React.Component {
    constructor(props) {
        super(props);
        this.channel = props.channel;
        this.state = {
            inputValue: '',
            inputValue2: ''
        }

        this.channel.join()
            .receive("ok", this.gotView.bind(this))
            .receive("error", resp => { console.log("Unable to join", resp) });
    }

    /*
    State model:
     board: [{
        val: "A",
        status: { hidden, guessed, correct },
        index: 123 }]
     lastGuessed: tile
     score: 123
     wait: bool
     */
    gotView(view) {
        console.log("new view", view);
    }

    setupGame() {
        let boardPeices = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H'];
        boardPeices = _.shuffle(boardPeices.concat(boardPeices));
        let board = [];
        boardPeices.forEach((item, i) => board.push({
            val: item,
            status: Status.HIDDEN,
            index: i
        }));
        return {
            board: board,
            lastGuessed: null,
            score: 0,
            wait: false
        };
    }

    restart() { this.setState(this.setupGame()); }

    sleep(milliseconds) { return new Promise(resolve => setTimeout(resolve, milliseconds)) };

    clickTile(tile) { //only bound to hidden tiles
        if (this.state.wait === true) { return; }
        let lastGuessed = this.state.lastGuessed;
        let newBoard = this.state.board.slice();
        if (lastGuessed === null) { //first part of guess
            tile.status = Status.GUESSED;
            newBoard[tile.index] = tile;
            this.setState({lastGuessed: tile, board: newBoard});
        } else if (lastGuessed.val === tile.val) { //correct guess
            tile.status = Status.CORRECT;
            lastGuessed.status = Status.CORRECT;
            newBoard[tile.index] = tile;
            newBoard[lastGuessed.index] = lastGuessed;
            let score = this.state.score + 10;
            this.setState({lastGuessed: null, board: newBoard, score: score});
        } else { //incorrect guess
            tile.status = Status.GUESSED;
            newBoard[tile.index] = tile;
            let score = this.state.score - 1;
            this.setState({board: newBoard, wait: true, score: score});
            this.sleep(800).then(() => {
                tile.status = Status.HIDDEN;
                lastGuessed.status = Status.HIDDEN;
                let newBoard = this.state.board.slice();
                newBoard[tile.index] = tile;
                newBoard[lastGuessed.index] = lastGuessed;
                this.setState({lastGuessed: null, board: newBoard, wait: false});
            });
        }
    }

    updateInputValue(evt) {
        this.setState({
                          inputValue: evt.target.value
                      });
    }

    updateInputValue2(evt) {
        this.setState({
                          inputValue2: evt.target.value
                      });
    }

    guess() {
        this.channel.push("guess", {index1: this.state.inputValue, index2: this.state.inputValue2})
            .receive("ok", this.gotView.bind(this));
    }

    render() {
        return (
            <div>
                <input value={this.state.inputValue} onChange={evt => this.updateInputValue(evt)}/>
                <input value={this.state.inputValue2} onChange={evt => this.updateInputValue2(evt)}/>
                <button onClick={this.guess.bind(this)}>Restart</button>
            </div>
        )
    }
    //    let restart = <div className="column" >
    //        <p>
    //            <button onClick={this.restart.bind(this)}>Restart</button>
    //        </p>
    //    </div>;
    //    let score = <div className="score">{'Score: ' + this.state.score}</div>;
    //    let rows = [];
    //    for (let i = 0; i < this.state.board.length; i++) {
    //        if (i % 4 === 0) {
    //            rows.unshift([]);
    //        }
    //        rows[0].push(<Tile tile={this.state.board[i]} clickTile={this.clickTile.bind(this)} key={i} />);
    //    }
    //    let board = _.map(rows, (row, i) => {return <div className="row" key={i}>{row}</div>;});
    //
    //    return (
    //        <div >
    //            <h3>Memory Game</h3>
    //            {board}
    //            <div className="row">
    //                {score}
    //            </div>
    //            <div className="row">
    //                {restart}
    //            </div>
    //        </div>
    //    );
    //}
}

const Status = Object.freeze({
         HIDDEN: Symbol("hidden"),
         GUESSED: Symbol("guessed"),
         CORRECT: Symbol("correct")
     });

function Tile(props) {
    let tile = props.tile;
    if (tile.status === Status.HIDDEN) {
        return <div className="column tile hidden" onClick={() => props.clickTile(tile)}/>;
    } else {
        return(
            <div className="column tile shown">
                {tile.val}
            </div>
        );
    }

}