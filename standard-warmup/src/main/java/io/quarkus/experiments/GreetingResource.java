package io.quarkus.experiments;

import jakarta.ws.rs.GET;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.core.MediaType;

@Path("/hello")
public class GreetingResource {

    @GET
    @Produces(MediaType.TEXT_PLAIN)
    public String hello() {
        return "Hello from Quarkus REST";
    }

    @Path( "quit" )
    @Produces((MediaType.TEXT_PLAIN))
    public String quit() {
        new Thread() {
            public void run() {
				try {
					Thread.sleep( 200 );
				}
				catch (InterruptedException e) {
					throw new RuntimeException( e );
				}
				System.out.println("Shutting down");
                System.exit( 0 );
			}
        }.start();
        return "Quit from Quarkus REST";
    }
}
