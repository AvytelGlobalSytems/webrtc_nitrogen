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
         code_change/3]).

-define(SERVER, ?MODULE).

-record(state, {offer, frompid}).

start() ->
	gen_server:start({local, ?SERVER}, ?MODULE, [], []).

start_link() ->
        gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).

init([]) ->
        {ok, #state{}}.

handle_call(_Request, _From, State) ->
        {reply, ok, State}.

handle_cast({offer, Offer, Pid}, State=#state{offer=undefined, frompid=undefined}) ->
	{noreply, State#state{offer=Offer, frompid=Pid}};
handle_cast({offer, OfferA, PidA}, State=#state{offer=OfferB, frompid=PidB}) ->
	PidA ! {offer, OfferB},
	PidB ! {offer, OfferA},
	{noreply, State#state{offer=undefined, frompid=undefined}}.
handle_info(_Info, State) ->
        {noreply, State}.
terminate(_Reason, _State) ->
        ok.
code_change(_OldVsn, State, _Extra) ->
        {ok, State}.



