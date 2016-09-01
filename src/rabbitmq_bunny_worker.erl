%%%-------------------------------------------------------------------
%%% @author ycc
%%% @copyright (C) 2016, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 01. 九月 2016 10:40
%%%-------------------------------------------------------------------
-module(rabbitmq_bunny_worker).
-author("ycc").

-include("rabbit_bunny.hrl").
%% API
-export([subscribe/2]).



-spec subscribe(pid, binary) -> any.
subscribe(Channel, Queue) ->
  amqp_channel:call(Channel, #'basic.qos'{prefetch_count = 1}),
  amqp_channel:subscribe(Channel,
    #'basic.consume'{queue = Queue},
    self()),
  receive
    #'basic.consume_ok'{} ->
      ok
  end,
  loop(Channel).

loop(Channel) ->
  receive
    {#'basic.deliver'{delivery_tag = Tag}, #amqp_msg{payload = Body}} ->
      do_db(Body),
      io:format(" [x] Done~n"),
      amqp_channel:cast(Channel, #'basic.ack'{delivery_tag = Tag}),
      loop(Channel)
  end.

do_db(Body) ->
  io:format(" [x] Received ~p~n", [Body]).