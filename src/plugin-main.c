#include <obs-module.h>

struct vintage_filter {
	obs_source_t *source;
	gs_effect_t *effect;
};

static const char *vintage_filter_getname(void *unused)
{
	UNUSED_PARAMETER(unused);
	return obs_module_text("Vintage");
}

static void vintage_filter_destroy(void *data)
{
	struct vintage_filter *vf = data;

	obs_enter_graphics();
	gs_effect_destroy(vf->effect);
	obs_leave_graphics();

	bfree(vf);
}

static void vintage_filter_update(void *data, obs_data_t *settings)
{
	struct vintage_filter *vf = data;
	char *effect_file = NULL;

	const char *type = obs_data_get_string(settings, "type");

	if (strcmp(type, "blackWhite") == 0)
		effect_file = obs_module_file("black_white.effect");
	else if (strcmp(type, "sepia") == 0)
		effect_file = obs_module_file("sepia.effect");

	obs_enter_graphics();

	gs_effect_destroy(vf->effect);

	vf->effect = gs_effect_create_from_file(effect_file, NULL);
	bfree(effect_file);

	obs_leave_graphics();
}

static void *vintage_filter_create(obs_data_t *settings, obs_source_t *source)
{
	struct vintage_filter *vf = bzalloc(sizeof(struct vintage_filter));
	vf->source = source;
	vintage_filter_update(vf, settings);
	return vf;
}

static void vintage_filter_render(void *data, gs_effect_t *effect)
{
	struct vintage_filter *vf = data;

	if (!obs_source_process_filter_begin(vf->source, GS_RGBA,
				OBS_ALLOW_DIRECT_RENDERING))
		return;

	obs_source_process_filter_end(vf->source, vf->effect, 0, 0);

	UNUSED_PARAMETER(effect);
}

static obs_properties_t *vintage_filter_properties(void *data)
{
	obs_properties_t *props = obs_properties_create();

	obs_property_t *p = obs_properties_add_list(props, "type",
			obs_module_text("Type"),
			OBS_COMBO_TYPE_LIST, OBS_COMBO_FORMAT_STRING);
	obs_property_list_add_string(p,
			obs_module_text("blackWhite"), "blackWhite");
	obs_property_list_add_string(p,
			obs_module_text("Sepia"), "sepia");

	UNUSED_PARAMETER(data);
	return props;
}

struct obs_source_info vintage_filter = {
	.id             = "vintage_filter",
	.type           = OBS_SOURCE_TYPE_FILTER,
	.output_flags   = OBS_SOURCE_VIDEO | OBS_SOURCE_SRGB,
	.get_name       = vintage_filter_getname,
	.create         = vintage_filter_create,
	.destroy        = vintage_filter_destroy,
	.video_render   = vintage_filter_render,
	.update         = vintage_filter_update,
	.get_properties = vintage_filter_properties
};

OBS_DECLARE_MODULE()
OBS_MODULE_USE_DEFAULT_LOCALE("obs-vintage-filter", "en-US")

bool obs_module_load(void)
{
	obs_register_source(&vintage_filter);

	return true;
}

void obs_module_unload(void)
{
}
