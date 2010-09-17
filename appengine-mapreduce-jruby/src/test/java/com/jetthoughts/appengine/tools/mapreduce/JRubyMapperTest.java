package com.jetthoughts.appengine.tools.mapreduce;

import com.google.appengine.api.datastore.DatastoreService;
import com.google.appengine.api.datastore.DatastoreServiceFactory;
import com.google.appengine.tools.development.testing.LocalDatastoreServiceTestConfig;
import com.google.appengine.tools.development.testing.LocalServiceTestHelper;
import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.io.NullWritable;
import org.apache.hadoop.mapreduce.TaskAttemptID;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;

/**
 * Created by IntelliJ IDEA.
 * User: pftg
 * Date: Sep 11, 2010
 * Time: 9:51:17 PM
 */
public class JRubyMapperTest {
    private final LocalServiceTestHelper helper
            = new LocalServiceTestHelper(new LocalDatastoreServiceTestConfig());

    private DatastoreService datastoreService;
    private JRubyMapper mapper;
    private JRubyMapper.AppEngineContext context;


    @Before
    public void setUp() throws Exception {
        helper.setUp();
        mapper = new JRubyMapper();
        TaskAttemptID id = new TaskAttemptID("foo", 1, true, 1, 1);
        context = mapper.new AppEngineContext(new Configuration(false), id, null, null, null, null, null);
        datastoreService = DatastoreServiceFactory.getDatastoreService();
    }

    @After
    public void tearDown() throws Exception {
        helper.tearDown();
    }

    @Test
    public void testMap() throws Exception {
        mapper.setup(context);
        mapper.taskSetup(context);
        mapper.map(NullWritable.get(), NullWritable.get(), context);
        mapper.taskCleanup(context);
        mapper.cleanup(context);
    }

}
