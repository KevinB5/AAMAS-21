package loadingdocks;

import java.awt.Color;
import java.awt.Point;
import loadingdocks.Block.Shape;

/**
 * Agent behavior
 * @author Rui Henriques
 */
public class Agent extends Entity {

	public int direction = 90;
	public Box cargo;

	public Agent(Point point, Color color,Box cargo){ 
		super(point, color);
		this.cargo = cargo;
	} 
	
	public Agent(Point point, Color color){ 
		super(point, color);
	}
	
	/**********************
	 **** A: decision ***** 
	 **********************/
	
	public void agentDecision() {
		if (isWall()) {
			rotate();
		}else if (rampCell() && boxCell() && !boxCargo()){
			grabBox();
		}else if (boxCargo() && shelfCell() && (shelfColor() == cargoBoxColor()) && !boxCell()) {
			dropBox();
		}else if (!isFreeCell()) {
			rotate();
		}else if (random.nextInt(5)==0){
			rotate();
		}else {
			moveAhead();
		}
//		if(carryingBox() && boxAhead() && rampCell()) {
//			grabBox();
//		}else if( carryingBox() && shelfCell() && (color == colorAhead()) && boxAhead()) {
//			dropBox();
//		}else if (!isFreeCell() || isWall()) {
//			rotate();
//		}else {
//			moveAhead();
//		}
	}
	
	/********************/
	/**** B: sensors ****/
	/********************/
	
	/* Check if the cell ahead is floor (which means not a wall, not a shelf nor a ramp) and there are any robot there */
	protected boolean isFreeCell2() {
	  Point ahead = aheadPosition();
	  return Board.getBlock(ahead).shape.equals(Shape.free);
	}

	protected boolean boxAhead() {
		  Point ahead = aheadPosition();
		  if(!Board.getBlock(ahead).shape.equals(Shape.free) &&
				  !Board.getBlock(ahead).shape.equals(Shape.shelf)) {
			  return true;
		  }
		  return false;
	}
	
	protected boolean rampCell() {
		  Point ahead = aheadPosition();
		  return Board.getBlock(ahead).shape.equals(Shape.ramp);
	}
	
	protected boolean shelfCell() {
		  Point ahead = aheadPosition();
		  return Board.getBlock(ahead).shape.equals(Shape.shelf);
	}
	
	protected Color colorAhead() {
		  Point ahead = aheadPosition();
		  return Board.getBlock(ahead).color;
	}
	
	/* Check if the cell ahead is a wall */
	protected boolean isWall() {
		Point ahead = aheadPosition();
		return ahead.x<0 || ahead.y<0 || ahead.x>=Board.nX || ahead.y>=Board.nY;
	}
	
	protected boolean carryingBox() {
		return true;
	}

	/**********************/
	/**** C: actuators ****/
	/**********************/

	/* Rotate agent to right */
	public void rotate() {
		direction = (direction+90)%360;
	}
	
	/* Move agent forward */
	public void moveAhead() {
		Point ahead = aheadPosition();
		Board.updateEntityPosition(point,ahead);
		if(boxCargo())
			cargo.point = ahead;
		point = ahead;
	}
	
	/* Grab the box */
	public void grabBox() {
		Point ahead = aheadPosition();
		cargo = (Box)Board.getEntity(ahead);
		Board.removeEntity(ahead);
		cargo.point = point;
	}
	
	/* Drop the box */
	public void dropBox() {
		Point ahead = aheadPosition();
		Board.insertEntity(cargo,ahead);
		cargo.point = point;
		cargo = null;
	}
	
	/**********************/
	/**** D: auxiliary ****/
	/**********************/

	/* Position ahead */
	private Point aheadPosition() {
		Point newpoint = new Point(point.x,point.y);
		switch(direction) {
			case 0: newpoint.y++; break;
			case 90: newpoint.x++; break;
			case 180: newpoint.y--; break;
			default: newpoint.x--; 
		}
		return newpoint;
	}
	
	public boolean boxCargo() {
		return cargo!=null;
	}
	
	public Color cargoBoxColor() {
		return cargo.color;
	}
	
	public Color shelfColor() {
		Point ahead = aheadPosition();
		return Board.getBlock(ahead).color;
	}
	
	public boolean isFreeCell() {
		Point ahead = aheadPosition();
		return Board.getBlock(ahead).shape.equals(Shape.free)
				&& Board.getEntity(ahead)==null;
	}
	
	public boolean boxCell() {
		Point ahead = aheadPosition();
		Entity e = Board.getEntity(ahead);
		return e != null && e instanceof Box;
	}
	
	
}
