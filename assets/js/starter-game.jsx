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
            players: [],
            winner: null,
            nextTurn: null,
        };
        this.lastGuess = null;
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
        this.channel.push("restart")
            .receive("ok", this.gotView.bind(this));
    }

    sleep(milliseconds) { return new Promise(resolve => setTimeout(resolve, milliseconds)) };

    clickTile(index) { //only bound to hidden tiles
        if (this.user !== this.state.nextTurn) { return; }
        if (this.lastGuess === null) {
            this.lastGuess = index;
            this.channel.push("preview", {index1: index})
                .receive("ok", this.gotView.bind(this));
        } else {
            this.channel.push("guess", {index1: this.lastGuess, index2: index})
                .receive("ok", this.gotView.bind(this));
            this.lastGuess = null;
        }
    }

    render() {
        let players = _.map(this.state.players, (player, i) => {
            return <div className="row" key={i}>
                {player.name}: {player.corrects}
            </div>
        });
        let winner = "", restart = "", nextTurn = "";
        if (this.state.winner) {
            winner = <div className="row"><h1>{this.state.winner.corrects === 4 ? this.state.winner.name : this.state.winner.name + " wins!"}</h1></div>;
            restart =
                <a href="/">
                    <div className="button">Quit</div>
                </a>;
        } else {
            nextTurn = <div className="row" style={{fontWeight: 'bold'}}>Next turn: {this.state.nextTurn}</div>;
        }

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
                {winner}
                {nextTurn}
                {players}
                <div className="row">Current user: {this.user}</div>
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