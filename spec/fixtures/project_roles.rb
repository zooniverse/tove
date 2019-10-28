RSpec.shared_context "role parsing" do
  let(:raw_roles) {
    {"project_roles":
      [{"id": "10705",
        "roles": ["collaborator"],
        "href": "/project_roles/10705",
        "links":
         {"project": "1",
          "owner": {"id": "123", "type": "users", "href": "/users/123"}}},
       {"id": "10704",
        "roles": ["owner"],
        "href": "/project_roles/10704",
        "links":
         {"project": "2",
          "owner": {"id": "123", "type": "users", "href": "/users/123"}}},
       {"id": "3340",
        "roles": ["researcher"],
        "href": "/project_roles/3340",
        "links":
         {"project": "3",
          "owner": {"id": "123", "type": "users", "href": "/users/123"}}}],
    }
  }
end