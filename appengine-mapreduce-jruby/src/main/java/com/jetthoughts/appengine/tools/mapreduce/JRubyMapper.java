package com.jetthoughts.appengine.tools.mapreduce;

import com.google.appengine.tools.mapreduce.AppEngineMapper;
import com.google.appengine.tools.mapreduce.DatastoreInputFormat;
import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.mapreduce.*;

import javax.script.ScriptException;
import java.io.IOException;
import java.util.logging.Logger;

/**
 * Created by IntelliJ IDEA.
 * User: pftg
 * Date: Sep 11, 2010
 * Time: 8:14:23 PM
 */
public class JRubyMapper extends AppEngineMapper<Object, Object, Object, Object> {
    private static final Logger log = Logger.getLogger(JRubyMapper.class.getName());
    private JRubyEvaluator scriptEvaluator;


    @Override
    public void setup(Context context) throws IOException, InterruptedException {
        log.info("Invoke setup");
        super.setup(context);
    }

    @Override
    public void map(Object key, Object value, Context context) throws IOException, InterruptedException {
        log.info("Invoke map");

        try {
            JRubyEvaluator scriptEvaluator = getScriptEvaluator(context.getConfiguration());
            log.info("Script Evaluator: " + scriptEvaluator);

            scriptEvaluator.invoke("map", key, value, context);

        } catch (ScriptException e) {
            e.printStackTrace();
//            throw new RuntimeException(e);
        }
    }

    public static Configuration createConfiguration() {
        log.info("Invoke createConfiguration");

        Configuration result = new Configuration(false);
        result.setClass("mapreduce.map.class", JRubyMapper.class, Mapper.class);
        result.setClass("mapreduce.inputformat.class", DatastoreInputFormat.class, InputFormat.class);
        return result;
    }


    public JRubyEvaluator getScriptEvaluator(Configuration configuration) {
        if (scriptEvaluator == null) {
            scriptEvaluator = new JRubyEvaluator(configuration);
        }
        return scriptEvaluator;
    }
}