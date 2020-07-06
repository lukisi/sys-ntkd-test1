NULL =
ACLOCAL_AMFLAGS = -I m4

SUBDIRS = \
	neighborhood \
	identities \
	qspn \
	coordinator \
	hooking \
	$(NULL)

bin_PROGRAMS =  \
	sys_ntkd_test1 \
	$(NULL)

sys_ntkd_test1_SOURCES =  \
	main.vala \
	rngen.vala \
	commander.vala \
	fake_command_dispatcher.vala \
	serializables.vala \
	rpc/skeleton_factory.vala \
	rpc/module_skeletons.vala \
	rpc/stub_factory.vala \
	rpc/module_stubs.vala \
	neighborhood_helpers.vala \
	neighborhood_signals.vala \
	identities_helpers.vala \
	identities_signals.vala \
	qspn_helpers.vala \
	qspn_signals.vala \
	peers_helpers.vala \
	coordinator_helpers.vala \
	hooking_helpers.vala \
	hooking_signals.vala \
	identity_ip_commands.vala \
	identity_ip_compute.vala \
	table_names.vala \
	ipv4_compute.vala \
	update_graph.vala \
	neighborhood/neighborhood.vapi \
	identities/identities.vapi \
	qspn/qspn.vapi \
	coordinator/coord.vapi \
	hooking/hooking.vapi \
	$(NULL)

#	enter_network.vala \
#	migrate.vala \
#

sys_ntkd_test1_VALAFLAGS = \
	--vapidir $(GEE_PREFIX)/share/vala/vapi \
	--vapidir $(TASKLETSYSTEM_VAPIDIR) \
	--vapidir $(PTHTASKLET_VAPIDIR) \
	--vapidir $(NTKDCOMMON_VAPIDIR) \
	--vapidir $(NTKDRPC_VAPIDIR) \
	--vapidir $(PEERS_VAPIDIR) \
	--pkg gee-0.8 \
	--pkg ntkd-common \
	--pkg tasklet-system \
	--pkg pth-tasklet \
	--pkg ntkdrpc \
	--pkg peers \
	--pkg posix \
	$(NULL)

sys_ntkd_test1_CPPFLAGS = \
	-w \
	$(GOBJECT_CFLAGS) \
	$(GEE_CFLAGS) \
	$(NTKDCOMMON_CFLAGS) \
	$(TASKLETSYSTEM_CFLAGS) \
	$(PTHTASKLET_CFLAGS) \
	$(NTKDRPC_CFLAGS) \
	$(PEERS_CFLAGS) \
	-I$(srcdir)/neighborhood \
	-I$(srcdir)/identities \
	-I$(srcdir)/qspn \
	-I$(srcdir)/coordinator \
	-I$(srcdir)/hooking \
	$(NULL)

sys_ntkd_test1_LDADD = \
	-lm \
	$(GOBJECT_LIBS) \
	$(GEE_LIBS) \
	$(NTKDCOMMON_LIBS) \
	$(TASKLETSYSTEM_LIBS) \
	$(PTHTASKLET_LIBS) \
	$(NTKDRPC_LIBS) \
	$(PEERS_LIBS) \
	$(builddir)/neighborhood/libneighborhood.la \
	$(builddir)/identities/libidentities.la \
	$(builddir)/qspn/libqspn.la \
	$(builddir)/coordinator/libcoord.la \
	$(builddir)/hooking/libhooking.la \
	$(NULL)

