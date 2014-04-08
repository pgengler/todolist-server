(function() {

var App = Ember.Application.create();
App.ApplicationAdapter = DS.FixtureAdapter.extend();

Ember.Handlebars.helper('formatDate', function(value) {
	if (value) {
		return value.strftime('%a (%m/%d)');
	}
	return "--";
});

App.Router.map(function() {
	this.route('items');
});

App.ItemsRoute = Ember.Route.extend({
	model: function() {
		return this.store.find('item');
	}
});

App.ItemsController = Ember.ArrayController.extend({
	sortProperties: [ 'date', 'startTime', 'endTime', 'event', 'location' ]
});

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
	}.property('startTime', 'endTime'),

	rowClass: function() {
		var classes = [ ];
		if (this.get('done')) {
			classes.push('done');
		}
		var today = new Date();
		var date = this.get('date');
		if (!date) {
			classes.push('undated');
		} else if (datesEqual(date, today)) {
			classes.push('today');
		} else if (date < today) {
			classes.push('past');
		} else {
			classes.push('future');
		}
		return classes.join(' ');
	}.property('done', 'date')
});

App.Item.FIXTURES = [
	{ id: 1, done: false, date: new Date(), event: "Rewrite todolist UI with Ember", location: null, startTime: null, endTime: null },
	{ id: 2, done: true, date: new Date(), event: "Create some fixture data", location: null, startTime: null, endTime: null },
	{ id: 3, done: false, date: new Date(), event: "With a start time only", location: null, startTime: '0400', endTime: null },
	{ id: 4, done: false, date: new Date(), event: "With an end time only", location: null, startTime: null, endTime: '1600' },
	{ id: 5, done: false, date: new Date(), event: "With start and times", location: null, startTime: '0400', endTime: '1600' },
	{ id: 6, done: false, date: null, event: "Item without a date", location: null, startTime: null, endTime: null },
	{ id: 7, done: false, date: new Date("2014-04-07T23:59:59"), event: "Item with an older date", location: null, startTime: null, endTime: null }
];

function datesEqual(a, b)
{
	return (a.getFullYear() == b.getFullYear() && a.getMonth() == b.getMonth() && a.getDate() == b.getDate());
}

})();
