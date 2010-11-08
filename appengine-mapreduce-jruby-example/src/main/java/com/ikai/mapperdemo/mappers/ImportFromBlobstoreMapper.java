package com.ikai.mapperdemo.mappers;

import com.google.appengine.api.datastore.*;
import com.google.appengine.tools.mapreduce.AppEngineMapper;
import com.google.appengine.tools.mapreduce.BlobstoreRecordKey;
import org.apache.hadoop.io.NullWritable;

import java.util.logging.Logger;

/**
 * This Mapper imports from a CSV file in the Blobstore. The CSV
 * assumes it's in the MaxMind format for cities, states, zipcodes
 * and lat/long.
 *
 * @author Ikai Lan
 */
public class ImportFromBlobstoreMapper extends
        AppEngineMapper<BlobstoreRecordKey, byte[], NullWritable, NullWritable> {
    private static final Logger log = Logger.getLogger(ImportFromBlobstoreMapper.class
            .getName());

    @Override
    public void map(BlobstoreRecordKey key, byte[] segment, Context context) {

        String line = new String(segment);

        log.info("At offset: " + key.getOffset());
//        log.info("Got value: " + line);

        // Line format looks like this:
        // 10644,"US","VA","Tazewell","24651",37.0595,-81.5220,559,276
        // We're also assuming no errant commas in this simple example

        String[] values = line.split(",");
        String converted_body = values[0];


//        if (!converted_body.isEmpty()) {
        Entity page = new Entity("ScrapedPage");
//            try {
//                ZipInputStream stream = new ZipInputStream(new Base64DecoderStream(new ReaderInputStream(new StringReader(converted_body))));

//                new ByteArrayOutputStream().toByteArray()

//        page.setProperty("converted_body", new Blob());
        page.setProperty("body", new Text(converted_body));
        page.setProperty("converted_body", new Text(converted_body));

//            } catch (Base64DecoderException e) {
//                log.severe(e.getLocalizedMessage());
//            }

        DatastoreService datastoreService = DatastoreServiceFactory.getDatastoreService();
        datastoreService.put(page);

        log.info("Put page --------------------------------------------------\n\n\n\n");
//        this.getAppEngineContext(context).getMutationPool().put(page);
//        }

    }
}
