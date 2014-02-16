module.exports = function(grunt) {
	// Project configuration.
	grunt.initConfig({
		pkg: grunt.file.readJSON('package.json'),
		coffee: {
			compileJoined: {
				options: {
					join: true
				},
				files: {
					'build/<%= pkg.name %>.js': ['lib/*.coffee'] // concat then compile into single file
				}
			}
		}
	});

	grunt.loadNpmTasks('grunt-contrib-coffee');
	// Default task(s).
	grunt.registerTask('default', ['coffee']);
};
