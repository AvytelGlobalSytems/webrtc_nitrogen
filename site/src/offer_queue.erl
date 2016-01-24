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

-record(state, {notify_pid, receiver_pid}).

send_offer(ReceiverPid) ->
	gen_server:cast(?SERVER, {offer, self(), ReceiverPid}),
	receive
		{CR, OtherPid} when CR == caller orelse CR==receiver ->
			case is_pid(OtherPid) andalso is_process_alive(OtherPid) of
				true ->
					error_logger:info_msg("Connecting to ~p",[OtherPid]),
					{CR, OtherPid};
				false -> send_offer(ReceiverPid)
			end
	end.

start() ->
	gen_server:start({local, ?SERVER}, ?MODULE, [], []).

start_link() ->
	gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).

init([]) ->
	{ok, #state{}}.

handle_call(_Req, _From, State) ->
	{reply, ok, State}.

handle_cast({offer, NotifyPid, ReceiverPid}, State=#state{notify_pid=undefined, receiver_pid=undefined}) ->
	{noreply, State#state{notify_pid=NotifyPid, receiver_pid=ReceiverPid}};
handle_cast({offer, NotifyPidA, ReceiverPidA}, State=#state{notify_pid=NotifyPidB, receiver_pid=ReceiverPidB}) ->
	NotifyPidA ! {receiver, ReceiverPidB},
	NotifyPidB ! {caller, ReceiverPidA},
	{noreply, State#state{notify_pid=undefined, receiver_pid=undefined}}.

handle_info(_Info, State) ->
	{noreply, State}.

terminate(_Reason, _State) ->
	ok.

code_change(_OldVsn, State, _Extra) ->
	{ok, State}.



