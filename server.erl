%% Author: William Woodward, completed on 5/7/14. Code is original, referenced erlang website. Will be demoed on 5/8/14.

-module(server).
-export([start/0, loop/1, check_result/1, remove_userList/2]).

start() -> 
      register(xserver, spawn(server,loop, [[]])),
      io:format("Server has been initialized ~n", []). 
    
loop(User_List) ->
       receive  
                {already_chatting, FromPid} ->
                 FromPid ! {already_in_chat};    
		
                {go_off, Name} ->
                 New_User_List = remove_userList(Name, User_List),
                 loop(New_User_List); 
                
                {From, RealName, to_client} ->
                 case lists:keysearch(RealName, 2, User_List) of
                  false ->
                   New_User_List = update_userList(From, RealName, User_List),
                   io:format("~p has connected to the server ~n", [list_to_atom(RealName)]),
                   From ! {added_to_chat, RealName},
                   loop(New_User_List);
                 {value, {ToPid, Name}}->
                   From ! {user_already_logged_on}
                  end;  
                
                 {From, FromName, ToPid, ToName, chat_result, Result} ->
                  NewResult = check_result(Result),
                  case NewResult of
                   true ->
                    ToPid ! {user_accepts_chat, From, FromName},
                    From ! {user_added_to_chat, ToPid, ToName};  
                    _ ->
                     ToPid ! {user_rejects_chat}
                   end;
                
                 {From, UserName, RealName, request_to_client} ->
                  io:format("Requesting client: ~p~n", [RealName]),
                   case lists:keysearch(RealName, 2, User_List) of
                    false ->
                      io:format("User isn't logged on! ~n",[]),
                      From ! {user_not_logged_on};
                   {value, {ToPid, To}} ->
                      ToPid ! {user_wants_to_chat, UserName, From, RealName}
                     end
         end,
            loop(User_List).



update_userList(From, RealName, User_List)->
          [{From, RealName} | User_List].

remove_userList(ToName, User_List) ->
          lists:keydelete(ToName, 2, User_List).

check_result(Result) ->
    case string:equal(Result, "yes\n") of
       true ->
             true;
      _ ->
             false
end.
