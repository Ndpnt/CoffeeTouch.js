module.exports = function(grunt) {
	// Project configuration.
	grunt.initConfig({
		pkg: grunt.file.readJSON('package.json'),
		coffee: {
			compileForTest: {
				options: {
					bare: true
				},
				files: {
					'tmp/Analyzer.js': ['src/Analyzer.coffee'],
					'tmp/EventRouter.js': ['src/EventRouter.coffee'],
					'tmp/Finger.js': ['src/Finger.coffee'],
					'tmp/MethodsHelper.js': ['src/MethodsHelper.coffee'],
					'tmp/StateMachine.js': ['src/StateMachine.coffee']
				}
			},
			compileJoined: {
				options: {
					join: true
				},
				files: {
					'build/<%= pkg.name %>.js': ['src/*.coffee'] // concat then compile into single file
				}
			}
		},
		uglify: {
			options: {
				banner: '/*! <%= pkg.name %> v<%= pkg.version %> - <%= grunt.template.today("yyyy-mm-dd") %> */\n'
			},
			build: {
				src: 'build/<%= pkg.name %>.js',
				dest: 'build/<%= pkg.name %>.min.js'
			}
		},
		jasmine: {
			src: 'tmp/*.js',
			options: {
				vendor: [
					'bower_components/jquery/dist/jquery.js',
					'bower_components/jasmine-jquery/lib/jasmine-jquery.js'
				],
				specs: 'spec/*Spec.js',
				helpers: 'spec/*Helper.js',
				template: require('grunt-template-jasmine-istanbul'),
					templateOptions: {
						coverage: 'coverage/coverage.json',
						report: 'coverage'
					}
			}
		},
		clean: ['tmp']
	});

	grunt.loadNpmTasks('grunt-contrib-uglify');
	grunt.loadNpmTasks('grunt-contrib-coffee');
	grunt.loadNpmTasks('grunt-contrib-jasmine');
	grunt.loadNpmTasks('grunt-contrib-clean');

	// Default task(s).
	grunt.registerTask('default', ['coffee:compileJoined', 'uglify']);
	grunt.registerTask('test', ['coffee:compileForTest', 'jasmine', 'clean']);
};
