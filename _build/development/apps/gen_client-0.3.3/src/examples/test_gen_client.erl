%% Author: bokner
%% Created: May 1, 2010
%% Description: TODO: Add description to test_gen_client
-module(test_gen_client).

%%
%% Include files
%%

%%
%% Exported Functions
%%
-export([test_subscriptions/0]).

%%
%% API Functions
%%
test_subscriptions() ->
	NodeOwner = "node_owner@localhost",
	SameDomainAcc = "test@localhost",
	ForeignDomainAcc = "test@units.vroc.local",
	{ok, S1} = gen_client:start(NodeOwner, "vroc.oksphere.com", 7222, "node_owner", [{module, dummy_client, ["Node Owner has started"]}, {reconnect, 5000}]),
	{ok, S2} = gen_client:start(SameDomainAcc, "vroc.oksphere.com", 5222, "test", [{module, dummy_client, ["Client1 has started"]}, {reconnect, 5000}]),	
	{ok, S3} = gen_client:start(ForeignDomainAcc, "vroc.oksphere.com", 5222, "test", [{module, dummy_client, ["Client2 has started"]}, {reconnect, 5000}]),
	timer:sleep(5000),
	gen_client:send_sync_packet(S1, 
															stanza:create_pubsub_node("pubsub.localhost", "test_node", leaf, 
																												 [{"pubsub#collection", ""}, %% Assosiates itself with 1st level nodes
																													{"pubsub#presence_based_delivery", "true"}
																												]), 
															5000),
																[Item] = exmpp_xml:parse_document(
																	"<entry xmlns='http://www.w3.org/2005/Atom'><item>Test Item</item></entry>"
																												),

	
	gen_client:send_sync_packet(S1, stanza:publish_with_itemid("pubsub.localhost", "test_node", Item, "test_item_id"),
															5000),


	gen_client:send_packet(S2, exmpp_client_pubsub:subscribe(SameDomainAcc, "pubsub.localhost", "test_node")),
	gen_client:send_packet(S3, exmpp_client_pubsub:subscribe(ForeignDomainAcc, "pubsub.localhost", "test_node")).

%%
%% Local Functions
%%

