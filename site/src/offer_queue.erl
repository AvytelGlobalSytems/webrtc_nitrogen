-module(offer_queue).

-behaviour(gen_server).

%% API
-export([start_link/0, start/0]).

%% gen_server callbacks
-export([init/1,
         handle_call/3,
         handle_cast/2,
         handle_info/2,
         terminate/2,
         code_change/3,
		 send_offer/1
		]).

-define(SERVER, ?MODULE).

-record(state, {peer_id, notify_pid}).

send_offer(Peerid) ->
	gen_server:cast(?SERVER, {offer, self(), Peerid}),
	receive
		{CR, OtherPeerid} when CR == caller orelse CR==receiver ->
			{CR, OtherPeerid}
	end.

start() ->
	gen_server:start({local, ?SERVER}, ?MODULE, [], []).

start_link() ->
	gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).

init([]) ->
	{ok, #state{}}.

handle_call(_Req, _From, State) ->
	{reply, ok, State}.

handle_cast({offer, NotifyPid, Peerid}, State=#state{peer_id=undefined}) ->
	error_logger:info_msg("Adding Peerid: ~p",[Peerid]),
	{noreply, State#state{notify_pid=NotifyPid, peer_id=Peerid}};
handle_cast({offer, NotifyPidA, PeeridA}, State=#state{notify_pid=NotifyPidB, peer_id=PeeridB}) ->
	error_logger:info_msg("Informing Peers of a match.~n~p <= ~p~n~p <= ~p~n", [NotifyPidA, PeeridB, NotifyPidB, PeeridA]),
	NotifyPidA ! {receiver, PeeridB},
	NotifyPidB ! {caller, PeeridA},
	{noreply, State#state{notify_pid=undefined, peer_id=undefined}}.

handle_info(_Info, State) ->
	{noreply, State}.

terminate(_Reason, _State) ->
	ok.

code_change(_OldVsn, State, _Extra) ->
	{ok, State}.



