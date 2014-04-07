var App = Ember.Application.create();
App.ApplicationAdapter = DS.FixtureAdapter;

App.Item = DS.Model.extend({
	done: DS.attr('boolean'),
	date: DS.attr('date'),
	event: DS.attr('string'),
	location: DS.attr('string'),
	startTime: DS.attr('number')
});

App.Item.FIXTURES = [
	{ id: 1, done: false, date: new Date(), event: "Rewrite todolist UI with Ember", location: null, startTime: null },
	{ id: 2, done: true, date: new Date(), event: "Create some fixture data", location: null, startTime: null }
];
