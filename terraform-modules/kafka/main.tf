// Create application
resource "heroku_app" "default" {
	name = var.name
	region = "us"
}
resource "heroku_addon" "default" {
	app = heroku_app.default.name
	plan = var.plan
}
