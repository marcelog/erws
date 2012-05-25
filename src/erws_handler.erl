-module(erws_handler).
-behaviour(cowboy_http_handler).
-behaviour(cowboy_http_websocket_handler).
-export([init/3, handle/2, terminate/2]).
-export([
    websocket_init/3, websocket_handle/3,
    websocket_info/3, websocket_terminate/3
]).

init({tcp, http}, Req, _Opts) ->
    lager:debug("Request: ~p", [Req]),
    {upgrade, protocol, cowboy_http_websocket}.

handle(Req, State) ->
    lager:debug("Request not expected: ~p", [Req]),
    {ok, Req2} = cowboy_http_req:reply(404, [{'Content-Type', <<"text/html">>}]),
    {ok, Req2, State}.

terminate(_Req, _State) ->
    ok.

websocket_init(_Any, Req, []) ->
    lager:debug("New client"),
    Req2 = cowboy_http_req:compact(Req),
    {ok, Req2, undefined, hibernate}.

websocket_handle({text, Msg}, Req, State) ->
    lager:debug("Got Data: ~p", [Msg]),
    {reply,
        {text, << "responding to ", Msg/binary >>}, Req, State, hibernate
    };

websocket_handle(_Any, Req, State) ->
    {ok, Req, State}.

websocket_info(_Info, Req, State) ->
    {ok, Req, State, hibernate}.

websocket_terminate(_Reason, _Req, _State) ->
    ok.