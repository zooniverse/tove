RSpec.shared_context "project parsing" do
  let(:raw_project) {
    {"projects":
      [{"id": "1715",
        "display_name": "ZTEST",
        "classifications_count": 0,
        "updated_at": "2019-09-20T02:20:00.710Z",
        "description": "A short description of the project",
        "slug": "zwolf/ztest",
        "redirect": "",
        "launch_approved": false,
        "avatar_src": "",
        "links": {}}]
    }
  }
end
