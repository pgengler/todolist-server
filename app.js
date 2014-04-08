var App = Ember.Application.create();
App.ApplicationAdapter = DS.FixtureAdapter.extend();

App.Router.map(function() {
	this.route('items');
});

App.ItemsRoute = Ember.Route.extend({
	model: function() {
		return this.store.find('item');
	}
});

App.ItemsController = Ember.ArrayController.extend();

App.Item = DS.Model.extend({
	done: DS.attr('boolean'),
	date: DS.attr('date'),
	event: DS.attr('string'),
	location: DS.attr('string'),
	startTime: DS.attr('number'),
	endTime: DS.attr('number'),

	time: function() {
		var startTime = this.get('startTime');
		var endTime = this.get('endTime');
		if (startTime && endTime) {
			return startTime + '-' + endTime;
		} else if (startTime) {
			return startTime;
		} else if (endTime) {
			return '-' + endTime;
		}
		return "";
	}.property('startTime', 'endTime')
});

App.Item.FIXTURES = [
	{ id: 1, done: false, date: new Date(), event: "Rewrite todolist UI with Ember", location: null, startTime: null, endTime: null },
	{ id: 2, done: true, date: new Date(), event: "Create some fixture data", location: null, startTime: null, endTime: null },
	{ id: 3, done: false, date: new Date(), event: "With a start time only", location: null, startTime: '0400', endTime: null },
	{ id: 4, done: false, date: new Date(), event: "With an end time only", location: null, startTime: null, endTime: '1600' },
	{ id: 5, done: false, date: new Date(), event: "With start and times", location: null, startTime: '0400', endTime: '1600' }
];
