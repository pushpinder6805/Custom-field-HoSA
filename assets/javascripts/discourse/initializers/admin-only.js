import { withPluginApi } from "discourse/lib/plugin-api";

export default {
  name: "admin-only-checkbox",

  initialize() {
    withPluginApi("0.8", (api) => {
      if (!api.getCurrentUser()?.admin) return;

      api.addComposerFieldsCallback(() => {
        return {
          admin_only: false,
        };
      });

      api.modifyClass("controller:composer", {
        pluginId: "admin-only-checkbox",
        adminOnlyEnabled: Ember.computed.alias("model.admin_only"),
      });

      api.modifyClass("component:composer-fields", {
        pluginId: "admin-only-checkbox",

        adminOnly: Ember.computed.alias("composerModel.admin_only"),

        didInsertElement() {
          this._super(...arguments);

          if (!this.siteSettings.topic_custom_field_enabled) return;

          const checkbox = document.createElement("input");
          checkbox.type = "checkbox";
          checkbox.checked = this.adminOnly;
          checkbox.id = "admin-only-toggle";
          checkbox.addEventListener("change", () => {
            this.set("composerModel.admin_only", checkbox.checked);
          });

          const label = document.createElement("label");
          label.htmlFor = "admin-only-toggle";
          label.innerText = "Admin Only";

          const wrapper = document.createElement("div");
          wrapper.classList.add("admin-only-checkbox");
          wrapper.appendChild(checkbox);
          wrapper.appendChild(label);

          this.element.querySelector(".composer-fields").appendChild(wrapper);
        },
      });
    });
  },
};
