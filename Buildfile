repositories.remote << 'http://www.ibiblio.org/maven2/'
repositories.remote << 'http://repository.codehaus.org'
repositories.remote << 'http://nexus.bedatadriven.com/content/repositories/thirdparty/'
repositories.remote << 'https://repository.apache.org'
repositories.remote << 'https://repository.apache.org/content/repositories/releases/'
repositories.remote << 'http://maven.atlassian.com/repository/public'
repositories.remote << 'http://maven.seasar.org/maven2'
repositories.remote << 'http://maven-gae-plugin.googlecode.com/svn/repository'
repositories.remote << 'https://oss.sonatype.org/content/repositories/google-snapshots/'

#repositories.local = '~/.m2/repository'


define 'appengine-mapreduce-app' do
  project.version = '0.0.5-SNAPSHOT'

  compile.options.lint = false
  test.compile.options.lint = false
  compile.options.target = '1.6'

  appengine_mapreduce_layout = Layout.new
  appengine_mapreduce_layout[:source, :main, :java] = 'src'
  appengine_mapreduce_layout[:source, :test, :java] = 'test'

  define 'appengine-mapreduce', :layout => appengine_mapreduce_layout do


    compile.
        with(Dir[_("lib/*.jar")]).
        with(transitive 'org.apache.geronimo.specs:geronimo-servlet_2.5_spec:jar:1.2').
        with(transitive 'com.google.appengine:appengine-api-labs:jar:1.4.0').
        with(transitive 'com.google.appengine:appengine-api-1.0-sdk:jar:1.4.0')


    compile do
      filter.
          from(_('static')).
          into(_('target/main/classes/com/google/appengine/tools/mapreduce/')).
          run
    end


    test.
        exclude('*Test').
        include('*AllTests').
        with(Dir[_("test_lib/*.jar")]).
        with(compile.dependencies).
        with(transitive 'com.google.appengine:appengine-testing:jar:1.4.0').
        with(transitive 'com.google.appengine:appengine-api-stubs:jar:1.4.0')

    package(:jar)
  end

  define 'appengine-mapreduce-jruby' do
    compile.
        with(project('appengine-mapreduce')).
        with(project('appengine-mapreduce').compile.dependencies).
        with(transitive 'org.jruby:jruby-complete:jar:1.5.6')

    test.
        with(transitive 'com.google.appengine:appengine-testing:jar:1.4.0').
        with(transitive 'com.google.appengine:appengine-api-stubs:jar:1.4.0')

    package(:jar)
  end

  define 'appengine-mapreduce-jruby-example' do

    compile.
        with(project('appengine-mapreduce-jruby')).
        with(project('appengine-mapreduce-jruby').compile.dependencies)

    package(:war)
  end
end