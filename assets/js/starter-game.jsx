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
            guessBoard: [],
            score: 0,
            players: []
        };
        this.lastGuess = null;
        this.wait = false;
        this.user = "";

        this.channel.join()
            .receive("ok", (m) => {
                this.user = m.user;
                this.gotView(m);
            })
            .receive("error", resp => { console.log("Unable to join", resp) });

        this.channel.on("new:msg", this.gotView.bind(this));
    }

    gotView(view) {
        console.log(view);
        this.setState(view.game);
        if (view.action === "guess") {
            this.sleep(800).then(() => {
                this.channel.push("getView")
                    .receive("ok", this.gotView.bind(this));
            });
        }
    }

    restart() {
        this.wait = false;
        this.channel.push("restart")
            .receive("ok", this.gotView.bind(this));
    }

    makeGuess(view) {
        this.gotView(view);
    }

    sleep(milliseconds) { return new Promise(resolve => setTimeout(resolve, milliseconds)) };

    clickTile(index) { //only bound to hidden tiles
        if (this.wait) { return; }
        if (this.lastGuess === null) {
            this.lastGuess = index;
            this.channel.push("preview", {index1: index})
                .receive("ok", this.gotView.bind(this));
        } else {
            this.channel.push("guess", {index1: this.lastGuess, index2: index})
                .receive("ok", this.makeGuess.bind(this));
            this.lastGuess = null;
        }
    }

    render() {
        let score = <div className="score">{'Score: ' + this.state.score}</div>;
        let restart = <div className="column" >
            <p>
                <button onClick={this.restart.bind(this)}>Restart</button>
            </p>
        </div>;
        let players = _.map(this.state.players, (player, i) => {
            return <div className="row" key={i}>
                Player: {player.name}  Corrects: {player.corrects}  Wrongs: {player.wrongs}
            </div>
        });
        console.log("here");
        console.log(players);
        let rows = [];
        for (let i = 0; i < this.state.guessBoard.length; i++) {
            if (i % 4 === 0) {
                rows.unshift([]);
            }
            rows[0].push(<Tile tile={this.state.guessBoard[i]} index={i} clickTile={this.clickTile.bind(this)} key={i} />);
        }
        let board = _.map(rows, (row, i) => {return <div className="row" key={i}>{row}</div>;});
        return (
            <div >
                {board}
                <div className="row">
                    {score}
                    Current user: {this.user}
                </div>
                {players}
                <div className="row">
                    {restart}
                </div>
            </div>
        );
    }
}

function Tile(props) {
    let tile = props.tile;
    let index = props.index;
    if (tile === false) {
        return <div className="column tile hidden" onClick={() => props.clickTile(index)}/>;
    } else {
        return(
            <div className="column tile shown">
                {tile}
            </div>
        );
    }

}