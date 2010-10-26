package com.jetthoughts.appengine.tools.mapreduce;

import org.apache.hadoop.conf.Configuration;
import org.jruby.embed.EmbedEvalUnit;
import org.jruby.embed.ScriptingContainer;

import javax.script.ScriptException;
import java.io.*;
import java.net.URISyntaxException;
import java.net.URL;
import java.security.AccessControlException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.logging.Logger;

/**
 * Created by IntelliJ IDEA.
 * User: pftg
 * Date: Sep 12, 2010
 * Time: 10:46:18 AM
 */
public class JRubyEvaluator {

    private static final Logger log = Logger.getLogger(JRubyEvaluator.class.getName());


    private static final String WRAPPER_FILE_NAME = "/com/jetthoughts/appengine/tools/mapreduce/ruby_wrapper.rb";

    private EmbedEvalUnit wrapper;


    /**
     * invoke count is limited so that memory leaking
     */
    private static final int INVOKE_LIMIT = 10000;

    private static int invokeCounter = 0;

    private ScriptingContainer rubyEngine;

    /**
     * ruby script name kicked by Java at first
     */
    private String mapperScript;


    public JRubyEvaluator(Configuration conf) {
        mapperScript = conf.get("mapreduce.ruby.script");


        setupEngine();
    }

    public Object invoke(String methodName, Object conf) throws ScriptException {
        Object self = this; // if receiver is null, should use toplevel.
        Object result = rubyEngine.callMethod(self, methodName, new Object[]{
                conf, mapperScript}, Object[].class);
        invokeCounter++;
        return result;
    }

    public Object invoke(String methodName, Object key, Object value,
                         Object context) throws ScriptException {
        Object self = this; // if receiver is null, should use toplevel.
        Object result = rubyEngine.callMethod(self, methodName, new Object[]{
                key, value, context},
                null);
        invokeCounter++;
        return result;
    }

    // check resouce and restart engine if over limit
    public void checkResource() {
        // now simply count because cannot check directly
        // ThreadContextMap in ThreadService seems to be leaked
        if (invokeCounter > INVOKE_LIMIT) {
            invokeCounter = 0;
            setupEngine();
        }
    }

    private void setupEngine() {
        rubyEngine = new ScriptingContainer();

        final Reader wrapperFile;

        try {
            wrapperFile = readRubyWrapperFile();
        } catch (FileNotFoundException e) {
            throw new RuntimeException("cannot find wrapper file", e);
        }

        try {
            // evaluate ruby library upfront
            String path = JRubyEvaluator.class.getResource("/").getPath();
            List<String> loadPaths = new ArrayList<String>(Arrays.asList(path.split(File.pathSeparator)));
            loadPaths.add(path + "/..");
            rubyEngine.getProvider().setLoadPaths(loadPaths);

            rubyEngine.runScriptlet(wrapperFile, WRAPPER_FILE_NAME);
//            if (mapperScript != null) {
                rubyEngine.runScriptlet(mapperScript);
//            }


        } catch (Exception e) {
            e.printStackTrace();
            throw new RuntimeException("runScriptlet: ", e);
        }
    }

    private Reader readRubyWrapperFile() throws FileNotFoundException {
        log.info("Loading wrapper: " + JRubyEvaluator.class.
                getResource(WRAPPER_FILE_NAME));
        InputStream is = JRubyEvaluator.class
                .getResourceAsStream(WRAPPER_FILE_NAME);

        if (is == null) {
            throw new FileNotFoundException(WRAPPER_FILE_NAME);
        }

        return new InputStreamReader(is);
    }

    private static InputStream getMapReduceXmlInputStream() throws FileNotFoundException {
        File currentDirectory = getContextPath();

        // Walk up the tree, looking for a WEB-INF/mapreduce.xml . We only expect
        // this file to exist in the root dir, but I can't figure out a good way
        // to find the root dir.
        try {
            while (currentDirectory != null) {
                File mapReduceFile = new File(currentDirectory.getPath() + File.separator + "WEB-INF"
                        + File.separator + WRAPPER_FILE_NAME);
                if (mapReduceFile.exists()) {
                    return new FileInputStream(mapReduceFile);
                }
                currentDirectory = currentDirectory.getParentFile();
            }
            throw new FileNotFoundException("Couldn't find mapreduce.xml");
        } catch (AccessControlException e) {
            throw new FileNotFoundException("Couldn't find mapreduce.xml (permission error)");
        }
    }

    protected static File getContextPath() throws FileNotFoundException {
        String path;
        try {
            // Gets the location of the containing JAR
            log.info("Gets the location of the containing JAR");
            URL codeSourceUrl = JRubyEvaluator.class.getProtectionDomain().getCodeSource().getLocation();
            log.info("Code Source URL " + codeSourceUrl);
            path = codeSourceUrl.toURI().getPath();
        } catch (URISyntaxException e) {
            throw new FileNotFoundException("Couldn't find " + WRAPPER_FILE_NAME);
        }
        File currentDirectory = new File(path);
        if (!currentDirectory.isDirectory()) {
            currentDirectory = currentDirectory.getParentFile();
        }
        return currentDirectory;
    }


}

