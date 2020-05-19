NULL =
ACLOCAL_AMFLAGS = -I m4

SUBDIRS = \
	neighborhood \
	$(NULL)

bin_PROGRAMS =  \
	sys_ntkd_alone \
	$(NULL)

sys_ntkd_alone_SOURCES =  \
	main.vala \
	commander.vala \
	fake_command_dispatcher.vala \
	serializables.vala \
	rpc/skeleton_factory.vala \
	rpc/module_skeletons.vala \
	rpc/stub_factory.vala \
	rpc/module_stubs.vala \
	neighborhood_helpers.vala \
	neighborhood/neighborhood.vapi \
	$(NULL)

sys_ntkd_alone_VALAFLAGS = \
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

sys_ntkd_alone_CPPFLAGS = \
	-w \
	$(GOBJECT_CFLAGS) \
	$(GEE_CFLAGS) \
	$(NTKDCOMMON_CFLAGS) \
	$(TASKLETSYSTEM_CFLAGS) \
	$(PTHTASKLET_CFLAGS) \
	$(NTKDRPC_CFLAGS) \
	$(PEERS_CFLAGS) \
	-I$(srcdir)/neighborhood \
	$(NULL)

sys_ntkd_alone_LDADD = \
	-lm \
	$(GOBJECT_LIBS) \
	$(GEE_LIBS) \
	$(NTKDCOMMON_LIBS) \
	$(TASKLETSYSTEM_LIBS) \
	$(PTHTASKLET_LIBS) \
	$(NTKDRPC_LIBS) \
	$(PEERS_LIBS) \
	$(builddir)/neighborhood/libneighborhood.la \
	$(NULL)

