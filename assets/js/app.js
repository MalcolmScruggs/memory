// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import css from "../css/app.css";

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import dependencies
//
import "phoenix_html";
import $ from "jquery";

// Import local files
//
// Local files can be imported directly using relative paths, for example:
import socket from "./socket"

import game_init from "./starter-game";

//let channel = socket.channel("games:default", {});
//channel.join()
//    .receive("ok", resp => { console.log("Joined successfully", resp) })
//    .receive("error", resp => { console.log("Unable to join", resp) });

function start() {
    let root = document.getElementById('root');
    if (root) {
        let channel = socket.channel("games:" + window.gameName, {});
        // We want to join in the react component.
        game_init(root, channel);
    }
}

$(start);

//$(() => {
//    let root = $('#root')[0];
//    //let chanel = socket.channel("games:" + window.gameName, {})
//    // Now that you are connected, you can join channels with a topic:
//    let channel = socket.channel("games:default", {});
//    game_init(root);
//});

